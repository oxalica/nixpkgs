{ lib, stdenv, fetchFromGitLab, meson, ninja, pkg-config, wayland-scanner
, libGL, wayland, wayland-protocols, libinput, libxkbcommon, pixman
, xcbutilwm, libX11, libcap, xcbutilimage, xcbutilerrors, mesa
, libpng, ffmpeg_4, xcbutilrenderutil, seatd, vulkan-loader, glslang
, nixosTests

, enableXWayland ? true, xwayland ? null
}:

stdenv.mkDerivation rec {
  pname = "wlroots";
  version = "0.16.0-dev";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "wlroots";
    repo = "wlroots";
    rev = "91943a68a6976ef7c4cc70afc07954a00fae678b";
    hash = "sha256-NHKi6UhcsKMy3jAPFHBqngtnl/OguO5ysH19ZasIuAc=";
  };

  # $out for the library and $examples for the example programs (in examples):
  outputs = [ "out" "examples" ];

  strictDeps = true;
  depsBuildBuild = [ pkg-config ];

  nativeBuildInputs = [ meson ninja pkg-config wayland-scanner glslang ];

  buildInputs = [
    libGL wayland wayland-protocols libinput libxkbcommon pixman
    xcbutilwm libX11 libcap xcbutilimage xcbutilerrors mesa
    libpng ffmpeg_4 xcbutilrenderutil seatd vulkan-loader
  ]
    ++ lib.optional enableXWayland xwayland
  ;

  mesonFlags =
    lib.optional (!enableXWayland) "-Dxwayland=disabled"
  ;

  postFixup = ''
    # Install ALL example programs to $examples:
    # screencopy dmabuf-capture input-inhibitor layer-shell idle-inhibit idle
    # screenshot output-layout multi-pointer rotation tablet touch pointer
    # simple
    mkdir -p $examples/bin
    cd ./examples
    for binary in $(find . -executable -type f -printf '%P\n' | grep -vE '\.so'); do
      cp "$binary" "$examples/bin/wlroots-$binary"
    done
  '';

  # Test via TinyWL (the "minimum viable product" Wayland compositor based on wlroots):
  passthru.tests.tinywl = nixosTests.tinywl;

  meta = with lib; {
    description = "A modular Wayland compositor library";
    longDescription = ''
      Pluggable, composable, unopinionated modules for building a Wayland
      compositor; or about 50,000 lines of code you were going to write anyway.
    '';
    inherit (src.meta) homepage;
    changelog = "https://gitlab.freedesktop.org/wlroots/wlroots/-/tags/${version}";
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ primeos synthetica ];
  };
}
