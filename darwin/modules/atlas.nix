{
  config,
  pkgs,
  lib,
  ...
}: {
  homebrew.taps = ["ariga/tap"];
  homebrew.brews = ["ariga/tap/atlas"];
  environment.systemPackages = [
    (pkgs.stdenv.mkDerivation {
      pname = "atlas-shell-completion";
      version = "0.0.1";
      dontUnpack = true; # no src
      nativeBuildInputs = [pkgs.installShellFiles];
      postInstall = ''
        installShellCompletion --cmd atlas \
        --bash <(${config.homebrew.brewPrefix}/atlas completion bash) \
        --fish <(${config.homebrew.brewPrefix}/atlas completion fish) \
        --zsh <(${config.homebrew.brewPrefix}/atlas completion zsh)
      '';
    })
  ];
}
