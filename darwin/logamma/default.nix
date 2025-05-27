{
  config,
  self,
  self',
  pkgs,
  ...
}:
{
  imports = [
    self.darwinModules.common
    ../modules/aerospace
    ../modules/aws.nix
    ../modules/emacs-plus
    ../modules/hammerspoon
    ../modules/kanata
    ../modules/podman.nix
    ../modules/sunbeam
    ../modules/terraform.nix
    ../modules/xcode.nix
  ];

  home-manager.users.${config.my.user.name} =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.nix-colors
        ../../nix/home/aider.nix
        ../../nix/home/asciinema.nix
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
      programs.aider.enable = true;
      programs.asciinema.enable = true;
      programs.passage.enable = true;
      programs.age-op.enable = true;
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
      home.sessionVariables = { };
      home.packages = with pkgs; [
        act
        actionlint
        checkov
        deno
        dive
        flyctl
        go-task
        google-cloud-sdk
        kcat
        mkcert
        pinact
        process-compose
        uv
        self'.packages.everything-fzf
        self'.packages.chrome-cli
      ];
      xdg.enable = true;
      manual.html.enable = true;
      home.stateVersion = "22.11";
    };

  programs.aerospace.enable = true;
  programs.emacs-plus.enable = true;
  programs.hammerspoon.enable = true;
  programs.podman-desktop.enable = true;
  programs.sunbeam.enable = false;
  programs.xcode.enable = true;

  services.kanata.enable = true;
  services.kanata.configFiles = [ ../../config/kanata/apple-macbook-16inch.kbd ];

  homebrew = {
    taps = [
      "abhinav/tap"
    ];
    brews = [
      "abhinav/tap/restack"
      "nss" # used by mkcert
    ];
    casks = [
      "1password-cli"
      "discord"
      "ghostty"
      "obs"
      "tailscale"
      # "1password" # currently installed manually
      # "obsidian" # currently installed manually
    ];
  };

  environment.systemPackages = with pkgs; [
    plistwatch
    libplist
  ];

  ids.gids.nixbld = 30000;
  nix.enable = false; # Determinate uses its own daemon to manage the Nix installation

  system.stateVersion = 5;
}
