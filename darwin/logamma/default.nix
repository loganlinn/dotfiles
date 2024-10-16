{
  self,
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    self.darwinModules.common
    self.darwinModules.home-manager
    ../modules/aerospace.nix
    ../modules/emacs-plus
    ../modules/karabiner-elements
    {
      homebrew.casks = [
        # "1password"
        "1password-cli"
      ];
    }
    {
      homebrew.taps = [ "ariga/tap" ];
      homebrew.brews = [ "ariga/tap/atlas" ];
      environment.systemPackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "atlas-shell-completion";
          version = "0.0.1";
          dontUnpack = true; # no src
          nativeBuildInputs = [ pkgs.installShellFiles ];
          postInstall = ''
            installShellCompletion --cmd atlas \
            --bash <(${config.homebrew.brewPrefix}/atlas completion bash) \
            --fish <(${config.homebrew.brewPrefix}/atlas completion fish) \
            --zsh <(${config.homebrew.brewPrefix}/atlas completion zsh)
          '';
        })
      ];
    }
  ];

  homebrew.brews = [
    "nss" # used by mkcert
  ];

  homebrew.casks = [
    "obs"
    "tailscale"
  ];

  services.karabiner-elements.enable = false;

  home-manager.users.logan =
    { options, config, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.nix-colors
        inputs.nixvim.homeManagerModules.nixvim
        ../../nix/home/dev
        ../../nix/home/dev/nodejs.nix
        ../../nix/home/pretty.nix
        ../../nix/home/kitty
        ../../nix/home/doom
        ../../nix/modules/programs/nixvim
      ];

      programs.nixvim = {
        enable = true;
        defaultEditor = true;
      };

      programs.kitty.enable = true;

      home.packages = with pkgs; [
        aws-vault
        awscli2
        mkcert
        nodePackages.typescript-language-server
        nodejs
        pls
        yarn
      ];

      home.stateVersion = "22.11";
    };

  environment.systemPackages = with pkgs; [
    clickhouse
    clickhouse-cli
  ];
}
