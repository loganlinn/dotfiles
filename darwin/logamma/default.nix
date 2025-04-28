{
  self,
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
    ../modules/hammerspoon
    ../modules/sunbeam
    ../modules/xcode.nix
    ../modules/terraform.nix
    {
      homebrew.casks = [ "ghostty" ]; # cask installs Ghostty.app bundle, CLI, man pages, and shell completions.
    }
    # https://github.com/abhinav/restack
    {
      homebrew.taps = [ "abhinav/tap" ];
      homebrew.brews = [ "abhinav/tap/restack" ];
    }
    # https://github.com/dhth/kplay
    {
      homebrew.taps = [ "dhth/tap" ];
      homebrew.brews = [ "dhth/tap/kplay" ];
    }
    # Utility for AWS CloudWatch Logs <https://github.com/TylerBrock/saw>
    {
      homebrew.taps = [ "TylerBrock/saw" ];
      homebrew.brews = [ "TylerBrock/saw/saw" ];
    }
  ];

  environment.systemPackages = with pkgs; [
    postgresql
    devenv
    plistwatch
    libplist
  ];

  homebrew.brews = [
    "nss" # used by mkcert
    # "terminal-notifier" # like notify-send
  ];

  homebrew.casks = [
    # "1password" # currently installed manually
    "1password-cli"
    "discord"
    "obs"
    # "obsidian" # currently installed manually
    "tailscale"
  ];

  hammerspoon.enable = true;

  programs.aerospace.enable = true;

  programs.xcode.enable = true;

  programs.sunbeam.enable = false;

  programs.emacs-plus.enable = true;

  services.postgresql.enable = false;

  system.stateVersion = 5;

  ids.gids.nixbld = 30000;

  nix.enable = false; # Determinate uses its own daemon to manage the Nix installation

  home-manager.users.logan =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.lib.file) mkOutOfStoreSymlink;
    in
    {
      imports = [
        self.homeModules.common
        self.homeModules.nix-colors
        ../../nix/home/claude
        ../../nix/home/dev
        ../../nix/home/dev/lua.nix
        ../../nix/home/dev/nodejs.nix
        ../../nix/home/dev/crystal.nix
        ../../nix/home/doom
        ../../nix/home/just
        ../../nix/home/kitty
        ../../nix/home/nixvim
        ../../nix/home/neovide.nix
        ../../nix/home/pretty.nix
        ../../nix/home/tmux.nix
        ../../nix/home/wezterm
        ../../nix/home/yazi
        ../../nix/home/yt-dlp.nix
      ];

      programs.age-op.enable = true;
      programs.claude.desktop.enable = true;
      programs.kitty.enable = true;
      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        plugins.lsp.servers.nixd.settings.options = {
          darwin.expr = ''(builtins.getFlake "${self}").darwinConfigurations.logamma.options'';
        };
      };
      programs.wezterm.enable = true;
      programs.zsh = {
        dirHashes = {
          gamma = "~/src/github.com/gamma-app/gamma";
        };
      };
      home.packages = with pkgs; [
        actionlint
        asciinema
        flyctl
        google-cloud-sdk
        kcat
        mkcert
        uv
        process-compose
      ];
      xdg.enable = true;
      home.stateVersion = "22.11";
    };
}
