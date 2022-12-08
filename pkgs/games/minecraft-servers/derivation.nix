{ lib, stdenv, makeWrapper, fetchurl, nixosTests, jre_headless, version, url, sha1 }:
stdenv.mkDerivation {
  pname = "minecraft-server";
  inherit version;

  src = fetchurl { inherit url sha1; };

  nativeBuildInputs = [ makeWrapper ];

  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    install -D -T $src $out/lib/minecraft/server.jar
    makeWrapper ${jre_headless}/bin/java $out/bin/minecraft-server \
      --add-flags "-jar $out/lib/minecraft/server.jar" \
      --append-flags "nogui"

    runHook postInstall
  '';

  dontUnpack = true;

  passthru = {
    tests = { inherit (nixosTests) minecraft-server; };
    updateScript = ./update.py;
  };

  meta = with lib; {
    description = "Minecraft Server";
    homepage = "https://minecraft.net";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfreeRedistributable;
    platforms = platforms.unix;
    maintainers = with maintainers; [ thoughtpolice tomberek costrouc jyooru ];
  };
}
