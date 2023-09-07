{ poetry2nix, fetchFromGitHub, ... }:

poetry2nix.mkPoetryScriptsPackage {
  projectDir = fetchFromGitHub {
    owner = "atreyasha";
    repo = "i3-balance-workspace";
    rev = "be948d1080706fef08d43f42197a9c8b2d5b433f";
    hash = "sha256-3stjbcfM50LvYdCrhuQgulamQ3nzt2AV9JgWjiMTPec=";
  };
}
