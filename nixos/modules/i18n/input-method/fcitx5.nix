{ config, pkgs, lib, ... }:

with lib;

let
  im = config.i18n.inputMethod;
  cfg = im.fcitx5;
  fcitx5Package = pkgs.fcitx5-with-addons.override { inherit (cfg) addons; };
in {
  imports = [
    (mkRemovedOptionModule [ "i18n" "inputMethod" "fcitx5" "enableRimeData" ] "Rime data is now always available for fcitx5-rime")
  ];

  options = {
    i18n.inputMethod.fcitx5 = {
      addons = mkOption {
        type = with types; listOf package;
        default = [];
        example = literalExpression "with pkgs; [ fcitx5-rime ]";
        description = ''
          Enabled Fcitx5 addons.
        '';
      };
    };
  };

  config = mkIf (im.enabled == "fcitx5") {
    i18n.inputMethod.package = fcitx5Package;

    environment.variables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      QT_PLUGIN_PATH = [ "${fcitx5Package}/${pkgs.qt6.qtbase.qtPluginPrefix}";
    };
  };
}
