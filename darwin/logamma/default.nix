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
    ../modules/kitty
    # ../modules/kanata
    # ../modules/opnix
    # ../modules/podman.nix
    ../modules/sketchybar.nix
    ../modules/sunbeam
    ../modules/xcode.nix
  ];

  modules.kitty.enable = true;

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
      # "abhinav/tap"
      "aws/tap"
      "bridgecrewio/tap"
      "dagger/tap"
      "minamijoyo/hcledit"
      "minamijoyo/tfmigrate"
      "minamijoyo/tfschema"
      "minamijoyo/tfupdate"
      "pulumi/tap"
      "tsonglew/dutis"
    ];
    brews = [
      {
        name = "postgresql@16";
        link = true;
      }
      # "abhinav/tap/restack"
      "aspell"
      "aws/tap/eksctl"
      # "bridgecrewio/tap/yor"
      "caddy"
      "cmake"
      "curl"
      "d12frosted/emacs-plus/emacs-plus@31"
      "ddcctl"
      "direnv"
      # "drewdeponte/oss/git-ps-rs"
      "duti"
      "felixkratz/formulae/sketchybar"
      "gcc"
      "gh"
      "git"
      "gnu-getopt"
      "grafana"
      "hashicorp/tap/terraform-ls"
      "hcledit"
      # "inframap"
      # "jq"
      # "just"
      "keith/formulae/zap"
      "kubernetes-cli"
      "lazyjournal"
      "ldcli"
      "libgccjit"
      "libtool"
      "libvterm"
      "localstack/tap/localstack-cli"
      "luarocks"
      # "mas"
      "minamijoyo/hcledit/hcledit"
      "minamijoyo/tfmigrate/tfmigrate"
      "minamijoyo/tfschema/tfschema"
      "minamijoyo/tfupdate/tfupdate"
      "mkcert"
      "nss"
      # "pngpaste"
      # "pomdtr/tap/sunbeam"
      "pulumi/tap/esc"
      "pulumi/tap/pulumi"
      "redis"
      # "ripgrep"
      # "temporal"
      # "terminal-notifier"
      "terragrunt"
      "tfenv"
      # "tofuutils/tap/tofuenv"
      "tsonglew/dutis/dutis"
      # "dagger/tap/dagger"
      # "drewdeponte/oss/alt"
      # "podlet"
      # "podman"
      # "podman-tui"
    ];
    casks = [
      "1password-cli"
      # "dbeaver-community"
      "discord"
      "ghostty"
      # "gimp"
      "hammerspoon"
      "hiddenbar"
      "inkscape"
      # "karabiner-elements"
      # "keybase"
      "obs"
      "sf-symbols"
      "tailscale-app"
      "dagger/tap/container-use"
      "nikitabobko/tap/aerospace"
      # "1password" # currently installed manually
    ];
  };
  ids.gids.nixbld = 30000;
  nix.enable = false; # Determinate uses its own daemon to manage the Nix installation
  system.stateVersion = 5;

  home-manager.users.${config.my.user.name} = {pkgs, ...}: {
    imports = [
      self.homeModules.common
      self.homeModules.nix-colors
      # self.homeModules.opnix
      ../../nix/home/aws
      ../../nix/home/dev
      ../../nix/home/dev/kubernetes.nix
      ../../nix/home/dev/lua.nix
      ../../nix/home/dev/javascript.nix
      ../../nix/home/docker.nix
      ../../nix/home/doom
      ../../nix/home/ghostty.nix
      ../../nix/home/just
      ../../nix/home/neovide.nix
      ../../nix/home/nixvim
      ../../nix/home/pet.nix
      ../../nix/home/pretty.nix
      ../../nix/home/television.nix
      ../../nix/home/terraform.nix
      ../../nix/home/tmux.nix
      ../../nix/home/wezterm
      ../../nix/home/yazi
      ../../nix/home/yt-dlp.nix
    ];

    home.packages = with pkgs; [
      (writeShellScriptBin "copilot-language-server" ''npx @github/copilot-language-server "$@"'')
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
      self'.packages.chrome-cli
      self'.packages.everything-fzf
      # step-cli
      # jujutsu
      # jjui
      # jj-fzf
      # lazyjj
    ];

    home.stateVersion = "22.11";

    programs.age-op.enable = true;
    programs.asciinema.enable = true;
    programs.fish.enable = true;
    programs.ghostty.enable = true;
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      plugins.lsp.servers.nixd.settings.options = {
        darwin.expr = ''(builtins.getFlake "${self}").darwinConfigurations.logamma.options'';
      };
    };
    programs.passage.enable = true;
    programs.wezterm.enable = true;
    programs.zsh = {
      dirHashes = {
        gamma-app = "$HOME/src/github.com/gamma-app";
        gamma = "$HOME/src/github.com/gamma-app/gamma";
      };
    };
    xdg.enable = true;
  };
}
