{ lib, stdenv
, fetchFromGitHub
, pkg-config
, cmake
, extra-cmake-modules
, gettext
, fcitx5
, librime
, rime-data
}:

stdenv.mkDerivation rec {
  pname = "fcitx5-rime";
  version = "5.0.13";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = version;
    sha256 = "sha256-/oQdBCDV5obSHw7dzdceC+zWHcNve3NDlA50GhvkK8o=";
  };

  cmakeFlags = [ "-DRIME_DATA_DIR=${rime-data}/share/rime-data" ];

  prePatch = ''
    substituteInPlace data/CMakeLists.txt \
       --replace 'DESTINATION "''${RIME_DATA_DIR}"' \
                 'DESTINATION "''${CMAKE_INSTALL_DATADIR}/rime-data"'
  '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    gettext
  ];

  buildInputs = [
    fcitx5
    librime
  ];

  meta = with lib; {
    description = "RIME support for Fcitx5";
    homepage = "https://github.com/fcitx/fcitx5-rime";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ poscat ];
    platforms = platforms.linux;
  };
}
