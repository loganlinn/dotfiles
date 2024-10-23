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
    ../modules/aws.nix
    ../modules/xcode.nix
    ./homebrew.nix
    # postgresql
    {
      environment.systemPackages = with pkgs; [
        postgresql
      ];
    }
    # atlas
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

  programs.xcode.enable = true;

  programs.emacs-plus.enable = true;

  services.karabiner-elements.enable = false;

  homebrew.brews = [
    "grafana"
  ];

  homebrew.casks = [
    "clickhouse"
  ];

  home-manager.users.logan = {
    imports = [
      self.homeModules.common
      self.homeModules.nix-colors
      inputs.nixvim.homeManagerModules.nixvim
      ../../nix/home/dev
      ../../nix/home/dev/nodejs.nix
      ../../nix/home/pretty.nix
      ../../nix/home/kitty
      ../../nix/home/doom
      ../../nix/home/yt-dlp.nix
      ../../nix/modules/programs/nixvim
    ];

    home.shellAliases.switch = "darwin-rebuild switch --flake $HOME/.dotfiles";

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
    };

    programs.kitty.enable = true;

    home.packages = with pkgs; [
      devenv
      goose
      kcat
      mkcert
      nodePackages.typescript-language-server
      nodejs
      pls
      yarn
    ];

    home.stateVersion = "22.11";
  };
}
