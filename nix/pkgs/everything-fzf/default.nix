{
  bat,
  callPackage,
  fetchFromGitHub,
  fzf,
  jq,
  lib,
  makeWrapper,
  ripgrep,
  ruby,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "everything-fzf";

  version = src.rev;

  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "everything.fzf";
    rev = "0724725e5d84c7b3599a9dec63a3ccc6ec78b5de";
    hash = "sha256-4ygjqFV6XqBKnckD9e8htN3RK7ye1Tspgyzk6v4a8aE=";
  };

  dontBuild = true;

  runtimeDependencies =
    [
      bat
      fzf
      jq
      ripgrep
      ruby
    ]
    ++ lib.optionals stdenv.isDarwin [
      (callPackage ../chrome-cli { })
    ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin"
    find . -type f -executable -exec cp -t "$out/bin" {} \;
  '';

  postFixup = ''
    for file in "$out/bin/"*; do
      wrapProgram "$file" --prefix PATH : "${lib.makeBinPath runtimeDependencies}"
    done
  '';

  meta = with lib; {
    description = "Everything FZF scripts by junegunn";
    homepage = "https://github.com/junegunn/everything.fzf";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
