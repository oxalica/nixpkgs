{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  cudatoolkit,
  libdrm,
  ncurses,
  testers,
  udev,
  apple-sdk_12,
  addDriverRunpath,
  amd ? false,
  intel ? false,
  msm ? false,
  nvidia ? false,
  apple ? false,
  panfrost ? false,
  panthor ? false,
  ascend ? false,
}:

let
  drm-postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${
        lib.makeLibraryPath [
          libdrm
          ncurses
          udev
        ]
      }" \
      $out/bin/nvtop
  '';
  needDrm = (amd || intel || msm || panfrost || panthor);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nvtop";
  version = "0-unstable-20241230";

  src = fetchFromGitHub {
    owner = "Syllo";
    repo = "nvtop";
    rev = "c79a9c76fa2903d9ee2922d76848db0a5d9ff6b9";
    hash = "sha256-ckFi7NO79OFnHJlhek9zQsdCR308wxsMMGtJ7XrgnNo=";
  };

  cmakeFlags = with lib.strings; [
    (cmakeBool "BUILD_TESTING" true)
    (cmakeBool "USE_LIBUDEV_OVER_LIBSYSTEMD" true)
    (cmakeBool "AMDGPU_SUPPORT" amd)
    (cmakeBool "NVIDIA_SUPPORT" nvidia)
    (cmakeBool "INTEL_SUPPORT" intel)
    (cmakeBool "APPLE_SUPPORT" apple)
    (cmakeBool "MSM_SUPPORT" msm)
    (cmakeBool "PANFROST_SUPPORT" panfrost)
    (cmakeBool "PANTHOR_SUPPORT" panthor)
    (cmakeBool "ASCEND_SUPPORT" ascend)
  ];
  nativeBuildInputs = [
    cmake
    gtest
  ] ++ lib.optional nvidia addDriverRunpath;

  buildInputs =
    [ ncurses ]
    ++ lib.optional stdenv.isLinux udev
    ++ lib.optional stdenv.isDarwin apple-sdk_12
    ++ lib.optional nvidia cudatoolkit
    ++ lib.optional needDrm libdrm;

  # this helps cmake to find <drm.h>
  env.NIX_CFLAGS_COMPILE = lib.optionalString needDrm "-isystem ${lib.getDev libdrm}/include/libdrm";

  # ordering of fixups is important
  postFixup =
    (lib.optionalString needDrm drm-postFixup)
    + (lib.optionalString nvidia "addDriverRunpath $out/bin/nvtop");

  doCheck = true;

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      package = finalAttrs.finalPackage;
      command = "nvtop --version";
    };
  };

  meta = with lib; {
    description = "(h)top like task monitor for AMD, Adreno, Intel and NVIDIA GPUs";
    longDescription = ''
      Nvtop stands for Neat Videocard TOP, a (h)top like task monitor for AMD, Adreno, Intel and NVIDIA GPUs.
      It can handle multiple GPUs and print information about them in a htop familiar way.
    '';
    homepage = "https://github.com/Syllo/nvtop";
    changelog = "https://github.com/Syllo/nvtop/releases/tag/${finalAttrs.version}";
    license = licenses.gpl3Only;
    platforms = if apple then platforms.darwin else platforms.linux;
    maintainers = with maintainers; [
      willibutz
      gbtb
      anthonyroussel
      moni
    ];
    mainProgram = "nvtop";
  };
})
