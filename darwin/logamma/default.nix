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
      "jbangdev/tap/jbang"
      "wedow/tools/ticket"
    ];
    casks = [
      "1password-cli"
      "dagger/tap/container-use"
      "discord"
      "ghostty"
      "hammerspoon"
      "hiddenbar"
      "jordanbaird-ice"
      "mocki-toki/formulae/barik"
      "nikitabobko/tap/aerospace"
      "pearcleaner"
      "sf-symbols"
      "tailscale-app"
      "temurin@17"
      "vlc"
      # "inkscape"
      # "obs"
      # "visualvm"
      # "1password" # currently installed manually
      # "dbeaver-community"
      # "gimp"
      # "karabiner-elements"
      # "keybase"
    ];
  };
  ids.gids.nixbld = 30000;
  nix.enable = false; # Determinate uses its own daemon to manage the Nix installation
  system.stateVersion = 5;
  system.duti = {
    enable = true;
    settings = ''
      org.gnu.Emacs .json all
      org.gnu.Emacs .md   all
      org.gnu.Emacs .nix  all
      org.gnu.Emacs .org  all
      org.gnu.Emacs .rst  all
      org.gnu.Emacs .toml all
      org.gnu.Emacs .txt  all
      org.gnu.Emacs .yaml all
      org.videolan.vlc .mkv all
      org.videolan.vlc .mp3 all
      org.videolan.vlc .mp4 all
    '';
  };

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

    # mandb takes too long build every generation switch...
    # programs.fish.enable = true causes this to be set true by default
    programs.man.generateCaches = false;

    home.packages = with pkgs; [
      # step-cli
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
      jjui
      jnv
      jujutsu
      kcat
      mcat
      mkcert
      self'.packages.chrome-cli
      self'.packages.everything-fzf
    ];

    home.stateVersion = "22.11";

    programs.age-op.enable = true;
    programs.asciinema.enable = true;
    programs.fish.enable = false; # not used currently and slows builds down a bit.
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
      enable = true;
      dirHashes = {
        gamma-app = "$HOME/src/github.com/gamma-app";
        gamma = "$HOME/src/github.com/gamma-app/gamma";
      };
    };
    xdg.enable = true;
  };
}
