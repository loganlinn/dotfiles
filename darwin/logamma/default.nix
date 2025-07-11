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
    # ../modules/opnix
    ../modules/podman.nix
    ../modules/sketchybar.nix
    ../modules/sunbeam
    ../modules/xcode.nix
  ];

  home-manager.users.${config.my.user.name} =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.nix-colors
        # self.homeModules.opnix
        ../../nix/home/asciinema.nix
        ../../nix/home/dev
        ../../nix/home/dev/lua.nix
        ../../nix/home/dev/nodejs.nix
        ../../nix/home/docker.nix
        ../../nix/home/doom
        ../../nix/home/just
        ../../nix/home/kitty
        ../../nix/home/neovide.nix
        ../../nix/home/nixvim
        ../../nix/home/pretty.nix
        ../../nix/home/terraform.nix
        ../../nix/home/tmux.nix
        ../../nix/home/wezterm
        ../../nix/home/yazi
        ../../nix/home/yt-dlp.nix
      ];
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
        dry
        flyctl
        go-task
        google-cloud-sdk
        ipcalc
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

  services.kanata.enable = false;
  services.kanata.configFiles = [ ../../config/kanata/apple-macbook-16inch.kbd ];
  services.sketchybar.enable = false;
  # services.onepassword-secrets = {
  #   enable = true;
  #   users = [ "logan" ];
  #   # configFile = ./secrets.json;
  #   configFile = "${config.my.flakeDirectory}/darwin/logamma/secrets.json";
  # };

  homebrew = {
    taps = [
      "abhinav/tap"
      "yugabyte/tap"
      "bridgecrewio/tap"
    ];
    brews = [
      "abhinav/tap/restack"
      "alt"
      "borders"
      "bridgecrewio/tap/yor"
      "copilot-cli"
      "duti"
      "kanata"
      "lazyjournal"
      "ldcli"
      "localstack-cli"
      "nss" # used by mkcert
      "pngpaste"
      "podlet"
      "podman"
      "podman-compose"
      "podman-tui"
      "sunbeam"
      "terraform-ls"
      "yugabyte/tap/ybm"
    ];
    casks = [
      "1password-cli"
      "discord"
      "ghostty"
      "hiddenbar"
      "obs"
      "podman-desktop"
      "tailscale"
      # "1password" # currently installed manually
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
