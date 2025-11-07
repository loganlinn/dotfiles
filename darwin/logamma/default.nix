{
  config,
  self,
  self',
  pkgs,
  ...
}: {
  imports = [
    self.darwinModules.common
    ../modules/aerospace
    ../modules/emacs-plus
    ../modules/hammerspoon
    # ../modules/kanata
    # ../modules/opnix
    # ../modules/podman.nix
    ../modules/sketchybar.nix
    ../modules/sunbeam
    ../modules/xcode.nix
  ];

  home-manager.users.${config.my.user.name} = {pkgs, ...}: {
    imports = [
      self.homeModules.common
      self.homeModules.nix-colors
      # self.homeModules.opnix
      ../../nix/home/asciinema.nix
      ../../nix/home/aws
      ../../nix/home/dev
      ../../nix/home/dev/kubernetes.nix
      ../../nix/home/dev/lua.nix
      ../../nix/home/dev/javascript.nix
      ../../nix/home/docker.nix
      ../../nix/home/doom
      ../../nix/home/ghostty.nix
      ../../nix/home/just
      ../../nix/home/kitty
      ../../nix/home/neovide.nix
      ../../nix/home/nixvim
      ../../nix/home/nixvim/kitty.nix
      ../../nix/home/pet.nix
      ../../nix/home/pretty.nix
      ../../nix/home/television.nix
      ../../nix/home/terraform.nix
      ../../nix/home/tmux.nix
      ../../nix/home/wezterm
      ../../nix/home/yazi
      ../../nix/home/yt-dlp.nix
    ];

    programs.asciinema.enable = true;
    programs.passage.enable = true;
    programs.age-op.enable = true;
    programs.ghostty.enable = true;
    programs.kitty = {
      enable = true;
      package = pkgs.writeShellScriptBin "kitty" ''exec "''${HOMEBREW_PREFIX:-/opt/homebrew}/bin/kitty" "$@"'';
    };
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      plugins.lsp.servers.nixd.settings.options = {
        darwin.expr = ''(builtins.getFlake "${self}").darwinConfigurations.logamma.options'';
      };
    };
    programs.pet = {
      enable = true;
      snippets = [
      ];
    };
    programs.wezterm.enable = true;
    programs.zsh = {
      dirHashes = {
        gamma-app = "$HOME/src/github.com/gamma-app";
        gamma = "$HOME/src/github.com/gamma-app/gamma";
      };
    };
    home.packages = with pkgs; [
      # gemini-cli
      act
      actionlint
      checkov
      dive
      dry
      flyctl
      go-task
      google-cloud-sdk
      ipcalc
      jc
      jnv
      kcat
      mkcert
      # process-compose
      self'.packages.chrome-cli
      self'.packages.everything-fzf
      # step-cli

      # jujutsu
      # jjui
      # jj-fzf
      # lazyjj
    ];
    xdg.enable = true;
    # manual.html.enable = true;
    home.stateVersion = "22.11";
  };

  programs.aerospace.enable = true;
  programs.emacs-plus.enable = true;
  programs.hammerspoon.enable = true;
  programs.sunbeam.enable = false;
  programs.xcode.enable = true;

  # services.kanata.enable = false;
  # services.kanata.configFiles = [ ../../config/kanata/apple-macbook-16inch.kbd ];
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
      "aws/tap"
      "bridgecrewio/tap"
      "dagger/tap"
      "minamijoyo/hcledit"
      "minamijoyo/tfmigrate"
      "minamijoyo/tfschema"
      "minamijoyo/tfupdate"
      "pulumi/tap"
      "yugabyte/tap"
      # "minio/stable"
    ];
    brews = [
      {
        name = "postgresql@16";
        link = true;
      }
      "aws/tap/eksctl"
      "aspell"
      "caddy"
      "cmake"
      "curl"
      "ddcctl"
      "direnv"
      "duti"
      "gcc"
      "gh"
      "git"
      "gnu-getopt"
      "grafana"
      "hcledit"
      "inframap"
      "jq"
      "just"
      "kubernetes-cli"
      "lazyjournal"
      "ldcli"
      "libgccjit"
      "libtool"
      "libvterm"
      "luarocks"
      "mas"
      # "minio/stable/mc"
      "minamijoyo/hcledit/hcledit"
      "minamijoyo/tfmigrate/tfmigrate"
      "minamijoyo/tfschema/tfschema"
      "minamijoyo/tfupdate/tfupdate"
      "mkcert"
      "nss"
      "pngpaste"
      "redis"
      "ripgrep"
      "temporal"
      "terminal-notifier"
      "terragrunt"
      "tfenv"
      "abhinav/tap/restack"
      "bridgecrewio/tap/yor"
      "d12frosted/emacs-plus/emacs-plus@31"
      "drewdeponte/oss/git-ps-rs"
      "felixkratz/formulae/sketchybar"
      "hashicorp/tap/terraform-ls"
      "keith/formulae/zap"
      "localstack/tap/localstack-cli"
      "pomdtr/tap/sunbeam"
      "pulumi/tap/esc"
      "pulumi/tap/pulumi"
      "tofuutils/tap/tofuenv"
      "yugabyte/tap/ybm"
      # "dagger/tap/container-use"
      # "dagger/tap/dagger"
      # "drewdeponte/oss/alt:"
      # "podlet"
      # "podman"
      # "podman-tui"
    ];
    casks = [
      "1password-cli"
      "dbeaver-community"
      "discord"
      "ghostty"
      "gimp"
      "hammerspoon"
      "hiddenbar"
      "karabiner-elements"
      "keybase"
      "kitty"
      "obs"
      "sf-symbols"
      "snowflake-snowsql"
      "tailscale-app"
      "dagger/tap/container-use"
      "nikitabobko/tap/aerospace"
      # "1password" # currently installed manually
    ];
  };

  environment.systemPackages = with pkgs; [
    # plistwatch
    # libplist
  ];

  ids.gids.nixbld = 30000;
  nix.enable = false; # Determinate uses its own daemon to manage the Nix installation

  system.stateVersion = 5;
}
