{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  age,
}:
stdenv.mkDerivation rec {
  pname = src.repo;
  version = src.rev; # You may want to adjust this version
  src = fetchFromGitHub {
    owner = "stevelr";
    repo = "age-op";
    rev = "0b62a5c74e512edd04337e8e0aa67ff9ab20573b";
    hash = "sha256-dTExlO5uhJy7ARCJliFbrr8v+wErfO3MJIiLiaYNd74=";
  };
  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true; # Skip build phase since we just need to copy the file
  installPhase = ''
    mkdir -p $out/bin
    cp age-op $out/bin/
    chmod +x $out/bin/age-op

    wrapProgram $out/bin/age-op \
      --prefix PATH : ${lib.makeBinPath [ age ]}
  '';
  meta = with lib; {
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
