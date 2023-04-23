{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  Security,
  libiconv,
  Libsystem,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "procs";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "dalance";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-DoH9XxPRKGd+tex8MdbtkhM+V8C1wDMv/GZcB4aMCPc=";
  };

  cargoHash = "sha256-B+LpUErsvtLYn+Xvq4KNBpLR9WYe38yMWHUNsd9jIs8=";

  nativeBuildInputs = [ installShellFiles ];

  LIBCLANG_PATH = lib.optionals stdenv.isDarwin "${stdenv.cc.cc.lib}/lib/";

  postInstall = ''
    installShellCompletion --cmd procs \
      --bash <($out/bin/procs --gen-completion bash) \
      --fish <($out/bin/procs --gen-completion fish) \
      --zsh  <($out/bin/procs --gen-completion zsh)
  '';

  buildInputs = lib.optionals stdenv.isDarwin [ Security libiconv Libsystem ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A modern replacement for ps written in Rust";
    homepage = "https://github.com/dalance/procs";
    changelog = "https://github.com/dalance/procs/raw/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ Br1ght0ne SuperSandro2000 sciencentistguy ];
  };
}
