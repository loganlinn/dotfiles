{
  lib,
  stdenv,
  xcodebuild,
  xcbuildHook,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  name = "chrome-cli";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "prasmussen";
    repo = "chrome-cli";
    tag = version;
    hash = "sha256-w9pXu0f0rsTjl8o8IUm8oYEumFkvDV0Sos72J8lN9nc=";
  };

  buildInputs = [xcodebuild];

  nativeBuildInputs = [xcbuildHook];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -m755 --target-directory=$out/bin \
      Products/Release/chrome-cli \
      scripts/chrome-canary-cli \
      scripts/chromium-cli \
      scripts/brave-cli \
      scripts/vivaldi-cli \
      scripts/edge-cli \
      scripts/arc-cli

    runHook postInstall
  '';

  meta = {
    description = "Control Google Chrome from the command line";
    homepage = "https://github.com/prasmussen/chrome-cli";
    mainProgram = "chrome-cli";
    license = lib.licenses.mit;
    maintainers = []; # with lib.maintainers; [ loganlinn ];
    platforms = lib.platforms.darwin;
  };
}
