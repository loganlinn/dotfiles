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
    ../modules/sunbeam
    ../modules/xcode.nix
    # https://github.com/dhth/kplay?ref=terminaltrove
    {
      homebrew.taps = [ "dhth/tap" ];
      homebrew.brews = [ "dhth/tap/kplay" ];
    }
    # Utility for AWS CloudWatch Logs <https://github.com/TylerBrock/saw>
    {
      homebrew.taps = [ "TylerBrock/saw" ];
      homebrew.brews = [ "TylerBrock/saw/saw" ];
    }
    # terraform
    {
      homebrew.taps = [ "hashicorp/tap" ];
      homebrew.brews = [
        # "tfenv"
        "hashicorp/tap/terraform-ls"
      ];
      home-manager.users.logan = {
        home.packages = with pkgs; [
          tenv
          # terraform-ls
          tflint
          terraformer
          terraform-docs
          terraform-local
          tfsec
          tf-summarize
          iam-policy-json-to-terraform
        ];
      };
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
    # "terminal-notifier" # like notify-send
  ];

  homebrew.casks = [
    # "1password" # currently installed manually
    "1password-cli"
    # "clickhouse" # newer version than from nixpkgs
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

  programs.sunbeam.enable = false;

  programs.emacs-plus.enable = true;

  home-manager.users.logan = {
    imports = [
      self.homeModules.common
      self.homeModules.nix-colors
      inputs.nixvim.homeManagerModules.nixvim
      ../../nix/home/dev
      ../../nix/home/dev/lua.nix
      ../../nix/home/dev/nodejs.nix
      ../../nix/home/doom
      ../../nix/home/just
      ../../nix/home/kitty
      ../../nix/home/lazygit.nix
      ../../nix/home/pretty.nix
      ../../nix/home/tmux.nix
      ../../nix/home/wezterm
      ../../nix/home/yazi
      ../../nix/home/yt-dlp.nix
      ../../nix/modules/programs/nixvim
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      plugins.lsp.servers.nixd.settings.options = {
        darwin.expr = ''(builtins.getFlake "${self}").darwinConfigurations.logamma.options'';
      };
    };

    programs.kitty.enable = true;

    programs.wezterm.enable = true;

    home.packages = with pkgs; [
      google-cloud-sdk
      flyctl
      supabase-cli

      kcat

      bun
      mkcert
      nodejs
      pls
      process-compose
    ];

    xdg.enable = true;

    home.stateVersion = "22.11";
  };

  system.stateVersion = 4;
}
