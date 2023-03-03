# We split runtime dependencies out from the original derivation. They are more
# likely to be overriden when playing different versions of Minecraft. But we
# don't want to rebuild the launcher itself in that cases.
# But since the Qt wrapper relies on Qt dependencies inside
{ lib
, stdenv
, prismlauncher-unwrapped
, makeWrapper
, glfw
, libGL
, libX11
, libXcursor
, libXext
, libXrandr
, libXxf86vm
, libpulseaudio
, openal
, jdk8
, jdk17
, xrandr
, runCommand
, jdks ? [ jdk17 jdk8 ]
}:
runCommand "prismlauncher" {
  inherit (prismlauncher-unwrapped) version meta;

  nativeBuildInputs = [ makeWrapper ];

  runtimeLibraryPath = lib.makeLibraryPath [
    glfw
    libGL
    libX11
    libXcursor
    libXext
    libXrandr
    libXxf86vm
    libpulseaudio
    openal
    stdenv.cc.cc.lib
  ];

  # xorg.xrandr needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
  runtimePath = lib.makeBinPath [ xrandr ];

  passthru.unwrapped = prismlauncher-unwrapped;
} ''
  makeWrapper ${prismlauncher-unwrapped}/bin/prismlauncher $out/bin/prismlauncher \
    --set LD_LIBRARY_PATH "/run/opengl-driver/lib:$runtimeLibraryPath" \
    --prefix PRISMLAUNCHER_JAVA_PATHS : ${lib.makeSearchPath "bin/java" jdks} \
    --prefix PATH : "$runtimePath"
''
