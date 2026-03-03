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
        --bash <(${config.homebrew.prefix}/bin/atlas completion bash) \
        --fish <(${config.homebrew.prefix}/bin/atlas completion fish) \
        --zsh <(${config.homebrew.prefix}/bin/atlas completion zsh)
      '';
    })
  ];
}
