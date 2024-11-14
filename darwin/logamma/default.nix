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
    ../modules/aerospace
    ../modules/aws.nix
    ../modules/emacs-plus
    ../modules/karabiner-elements
    ../modules/sunbeam
    ../modules/xcode.nix
    {
      homebrew.taps = [ "TylerBrock/saw" ];
      homebrew.brews = [ "TylerBrock/saw/saw" ];
    }
    # dbeaver
    {
      homebrew.casks = [ "dbeaver-community" ];
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
    # terraform 
    {
      homebrew.taps = [ "hashicorp/tap" ];
      homebrew.brews = [
        "tfenv"
        "hashicorp/tap/terraform-ls"
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    postgresql
    devenv
    plistwatch
    libplist
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

  programs.aerospace = {
    enable = true;
    terminal.id = "com.github.wez.wezterm";
    editor.id = "org.gnu.Emacs";
  };

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
      ../../nix/home/dev/lua.nix
      ../../nix/home/doom
      ../../nix/home/just
      ../../nix/home/kitty
      ../../nix/home/pretty.nix
      ../../nix/home/wezterm
      ../../nix/home/yt-dlp.nix
      ../../nix/modules/programs/nixvim
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
    };

    programs.kitty.enable = true;

    programs.wezterm.enable = true;

    home.shellAliases.switch = "darwin-rebuild switch --flake $HOME/.dotfiles";

    home.packages = with pkgs; [
      goose
      kcat
      mkcert
      nodejs
      pls
      process-compose
      google-cloud-sdk
    ];

    home.stateVersion = "22.11";

    xdg.enable = true;
  };
}
