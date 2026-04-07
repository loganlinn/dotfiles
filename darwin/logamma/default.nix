{
  config,
  self,
  pkgs,
  lib,
  ...
}:
let
  # Determinate Nix owns /etc/nix/nix.conf and includes nix.custom.conf
  settingsToConf =
    attrs:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        k: v:
        let
          val =
            if lib.isList v then
              lib.concatStringsSep " " (map toString v)
            else if lib.isBool v then
              lib.boolToString v
            else
              toString v;
        in
        "${k} = ${val}"
      ) attrs
    );
in
{
  imports = [
    self.darwinModules.common
    ../modules/aerospace
    ../modules/emacs-plus
    ../modules/hammerspoon
    ../modules/homebrew-autoupdate.nix
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
  services.brewAutoupdate.enable = true;
  services.brewAutoupdate.only = [
    "aerospace"
    "borders"
    "codex"
    "crush"
    "curl"
    "gh"
    "git"
    "graphite"
    "hammerspoon"
    "karabiner-elements"
    "kitty"
    "kubernetes-cli"
    "llama.cpp"
    "ollama"
    "sem-cli"
    "terraform-ls"
  ];
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
      "docker-credential-helper-ecr"
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
      "llama.cpp"
      "localstack/tap/localstack-cli"
      "luarocks"
      # "mas"
      "minamijoyo/hcledit/hcledit"
      "minamijoyo/tfmigrate/tfmigrate"
      "minamijoyo/tfschema/tfschema"
      "minamijoyo/tfupdate/tfupdate"
      "mkcert"
      "nss"
      "ollama"
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
      "discord"
      "ghostty"
      "hammerspoon"
      "jordanbaird-ice"
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
  environment.etc."nix/nix.custom.conf".text = settingsToConf config.my.nix.settings;
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

  home-manager.users.${config.my.user.name} = import ../../home-manager/logamma.nix;
}
