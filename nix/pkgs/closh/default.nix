{ lib
, stdenv
, fetchurl
, installShellFiles
, jre_headless
, makeWrapper
, testers
}:

stdenv.mkDerivation rec {
  pname = "closh";
  version = "0.5.0";

  jarfilename = "${pname}-zero.jar";

  src = fetchurl {
    url = "https://github.com/dundalek/${pname}/releases/download/v${version}/${jarfilename}";
    sha256 = "sha256-pwONKWprqM0AY/bEf9k5YqSGXTwOSW0PXHr3H7HbPx0=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/java/${jarfilename}

    makeWrapper ${jre_headless}/bin/java $out/bin/${pname} \
      --argv0 ${pname} \
      --add-flags "-jar $out/share/java/${jarfilename}"

    runHook postInstall
  '';

  installCheckPhase = ''
    $out/bin/${pname} --version
  '';

  meta = with lib; {
    mainProgram = pname;
    homepage = "https://github.com/dundalek/closh";
    description = "Bash-like shell based on Clojure";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.epl10;
    platforms = jre_headless.meta.platforms;
    maintainers = [{ email = "logan@loganlinn.com"; github = "loganlinn"; name = "Logan Linn"; }];
  };
}
