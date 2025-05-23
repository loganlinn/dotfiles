{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  jdk,
}:
stdenv.mkDerivation rec {
  pname = "jib";
  version = "0.12.0";

  src = fetchzip {
    url = "https://github.com/GoogleContainerTools/jib/releases/download/v${version}-cli/jib-jre-${version}.zip";
    hash = "sha256-47kNpi6O+v7EP/R8FOrsrlnoKKEN64W0kx9FXjoaugM=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -R lib "$out/lib"
    install -Dm755 bin/jib "$out/bin/jib"
    patchShebangs "$out/bin"
    wrapProgram "$out/bin/jib" --prefix PATH : "$out/bin:${
      lib.makeBinPath [jdk]
    }"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Build container images for your Java applications";
    longDescription = ''
      Jib builds optimized Docker and OCI images for your Java applications without a Docker daemon - and without deep mastery of Docker best-practices.
    '';
    homepage = "https://github.com/GoogleContainerTools/jib";
    license = licenses.asl20;
    platforms = jdk.meta.platforms;
  };
}
