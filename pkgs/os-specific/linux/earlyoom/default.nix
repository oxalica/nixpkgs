{ lib, stdenv, fetchFromGitHub, pandoc, installShellFiles, withManpage ? false, nixosTests }:

stdenv.mkDerivation rec {
  pname = "earlyoom";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "rfjakob";
    repo = "earlyoom";
    rev = "v${version}";
    sha256 = "sha256-8YcT1TTlAet7F1U9Ginda4IApNqkudegOXqm8rnRGfc=";
  };

  nativeBuildInputs = lib.optionals withManpage [ pandoc installShellFiles ];

  patches = [
    ./fix-dbus-path.patch
    ./systemd-unit-enhancement.patch
  ];

  makeFlags = [
    "VERSION=${version}"
    "PREFIX=${placeholder "out"}"
    "SYSCONFDIR=${placeholder "out"}/etc"
  ];

  passthru.tests = {
    inherit (nixosTests) earlyoom;
  };

  meta = with lib; {
    description = "Early OOM Daemon for Linux";
    homepage = "https://github.com/rfjakob/earlyoom";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ oxalica ];
  };
}
