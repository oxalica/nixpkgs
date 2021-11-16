{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:
rustPlatform.buildRustPackage rec {
  pname = "dump_syms";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "dump_syms";
    rev = "v${version}";
    hash = "sha256-ZBhf6WbhGwLXLdog6c8aM9/gOW7F3kd/qCRqLAubHkU=";
  };

  cargoHash = "sha256-oEY9QB4O5ydOsNJDyAQz6ZdNEkyDO/vFskEfS50CSHs=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  # Tests try to access network.
  doCheck = false;

  meta = with lib; {
    description = "Rewrite of breakpad tools to generate breakpad symbol files from debug files";
    homepage = "http://www.mozilla.com/en-US/firefox/";
    license = with licenses; [ mit /* OR */ asl20 ];
    maintainers = with maintainers; [ oxalica ];
  };
}
