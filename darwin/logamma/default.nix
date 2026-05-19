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
    ../modules/cleanshot
    ../modules/kitty
    # ../modules/kanata
    # ../modules/opnix
    # ../modules/podman.nix
    ../modules/sketchybar.nix
    ../modules/sunbeam
    ../modules/xcode.nix
    ./homebrew.nix
  ];

  modules.kitty.enable = true;

  programs.cleanshot.enable = true;
  programs.aerospace.enable = true;
  programs.aerospace.borders.enable = true;
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
  networking.localHostName = "logamma";
  ids.gids.nixbld = 30000;
  nix.enable = false; # Determinate uses its own daemon to manage the Nix installation
  environment.etc."nix/nix.custom.conf".text = settingsToConf config.my.nix.settings;
  system.stateVersion = 5;
  system.duti = {
    enable = true;
    settings = ''
      net.kovidgoyal.kitty .command all
      org.gnu.Emacs .json all
      org.gnu.Emacs .md   all
      # .nix has no registered UTI on macOS; duti can't set handler for dynamic UTIs
      # org.gnu.Emacs .nix  all
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
