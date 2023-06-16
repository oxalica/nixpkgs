{ system ? builtins.currentSystem,
  config ? {},
  pkgs ? import ../.. { inherit system config; }
}:
let
  inherit (import ../lib/testing-python.nix { inherit system pkgs; }) makeTest;
  inherit (pkgs) lib;

  commonConfig = {
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 50; # Kill when available memory < 50%.
    };

    virtualisation.memorySize = 1024;

    systemd.services.testbloat = {
      description = "Consume exactly 512MiB memory without triggering systemwide OOM killer";
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = lib.getExe (pkgs.writeCBin "memory-eater" ''
        #include <assert.h>
        #include <stdlib.h>
        #include <string.h>
        #include <unistd.h>
        #define SIZE (512 << 20)
        int main() {
          void *ptr = malloc(SIZE);
          assert(ptr != NULL);
          memset(ptr, 42, SIZE);
          asm volatile ("" ::: "memory"); // Do not optimize out memset.
          sleep(1);
          return 0;
        }
      '');
    };
  };

  basic = makeTest {
    name = "earlyoom-basic";
    meta.maintainers = with lib.maintainers; [ ncfavier oxalica ];

    nodes.machine = commonConfig;

    testScript = ''
      machine.wait_for_unit("earlyoom.service")

      with subtest("earlyoom should kill the bad service"):
          machine.fail("systemctl start --wait testbloat.service")

          bloat_unit = machine.get_unit_info("testbloat.service")
          assert bloat_unit["Result"] == "signal"
          assert bloat_unit["KillSignal"] == "15" # SIGTERM

          assert machine.succeed("journalctl -u earlyoom.service --grep='sending SIGTERM to process'")
    '';
  };

  with-notification = makeTest {
    name = "earlyoom-with-notification";
    meta.maintainers = with lib.maintainers; [ oxalica ];

    nodes.machine = {
      imports = [
        commonConfig
        ./common/user-account.nix
        ../modules/profiles/minimal.nix
      ];

      services.earlyoom.enableNotifications = true;
      # Start it also in non-graphical environemnt.
      systemd.user.services.systembus-notify.wantedBy = [ "default.target" ];

      # Login is required for dbus and systembus-notify.
      services.getty.autologinUser = "alice";
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("dbus.service")
      machine.wait_for_unit("systembus-notify.service", user="alice")

      ${basic.testScript}

      with subtest("systembus should get a notification"):
          assert machine.succeed("su - alice -c 'journalctl --user -u systembus-notify.service --grep=\"Low memory! Killing process\"'")
    '';
  };

in {
  inherit basic with-notification;
}
