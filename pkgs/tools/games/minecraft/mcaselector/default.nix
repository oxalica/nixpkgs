{ lib
, stdenv
, fetchurl
, makeWrapper
, jre
}:
stdenv.mkDerivation rec {
  pname = "mcaselector";
  version = "1.17.2";

  # TODO: Compile from src
  src = fetchurl {
    url = "https://github.com/Querz/mcaselector/releases/download/${version}/${pname}-${version}.jar";
    sha256 = "sha256-rdWIZEo66cQK/W0TOusu3Tz0mdMNRblsjAaeYqrmA28=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ jre makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -D $src $out/lib/${pname}/${pname}-${version}.jar
    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/lib/${pname}/${pname}-${version}.jar"
  '';

  meta = with lib; {
    homepage = "https://github.com/Querz/mcaselector";
    description = "A tool to select chunks from Minecraft worlds for deletion or export";
    license = licenses.mit;
    maintainers = [ maintainers.oxalica ];
    platforms = platforms.linux;
  };
}
