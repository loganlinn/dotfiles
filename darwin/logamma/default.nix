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
    ../modules/aws.nix
    ../modules/emacs-plus
    ../modules/karabiner-elements
    ../modules/sunbeam
    ../modules/xcode.nix
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

  environment.systemPackages = with pkgs; [
    postgresql
    devenv
  ];

  homebrew.brews = [
    "grafana"
    "nss" # used by mkcert
    "terminal-notifier" # like notify-send
  ];

  homebrew.casks = [
    # "1password" # currently installed manually
    "1password-cli"
    "clickhouse" # newer version than from nixpkgs
    "discord"
    "obs"
    "tailscale"
  ];

  programs.xcode.enable = true;

  programs.sunbeam.enable = true;

  programs.emacs-plus.enable = true;

  services.karabiner-elements.enable = false;

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
