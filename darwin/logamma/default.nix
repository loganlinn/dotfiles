{
  self,
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
    ../modules/terraform.nix
    # https://book.git-ps.sh/
    {
      homebrew.taps = [ "drewdeponte/oss" ];
      homebrew.brews = [ "drewdeponte/oss/git-ps-rs" ];
    }
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
    "nss" # used by mkcert
    # "terminal-notifier" # like notify-send
  ];

  homebrew.casks = [
    # "1password" # currently installed manually
    "1password-cli"
    # "clickhouse" # newer version than from nixpkgs
    "discord"
    "obs"
    # "obsidian" # currently installed manually
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

  home-manager.users.logan =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.nix-colors
        ../../nix/home/dev
        ../../nix/home/dev/lua.nix
        ../../nix/home/dev/nodejs.nix
        ../../nix/home/doom
        ../../nix/home/hammerspoon.nix
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

      programs.zsh.dirHashes.gamma = "~src/github.com/gamma-app/gamma";
      programs.zsh.dirHashes.notes = "$HOME/Notes";

      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        plugins.lsp.servers.nixd.settings.options = {
          darwin.expr = ''(builtins.getFlake "${self}").darwinConfigurations.logamma.options'';
        };
        plugins.obsidian.settings.workspaces = [
          {
            name = "Primary";
            path = "~/Notes";
          }
        ];
      };

      programs.hammerspoon.enable = true;

      programs.wezterm.enable = true;

      programs.kitty.enable = true;

      programs.age-op.enable = true;

      home.packages = with pkgs; [
        asciinema
        bun
        flyctl
        google-cloud-sdk
        kcat
        mkcert
        nodejs
        pls
        process-compose
        supabase-cli
        uv
      ];

      xdg.enable = true;

      home.stateVersion = "22.11";
    };

  system.stateVersion = 4;
}
