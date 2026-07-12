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
    ../modules/sketchybar.nix
    ../modules/xcode.nix
    ./homebrew.nix
  ];

  environment.etc."nix/nix.custom.conf".text = settingsToConf config.my.nix.settings;

  networking.localHostName = "logamma";

  ids.gids.nixbld = 30000;
  my.user.uid = 502;

  modules.kitty.enable = true;

  programs.cleanshot.enable = true;
  programs.aerospace.enable = true;
  programs.emacs-plus.enable = true;
  programs.hammerspoon.enable = true;
  programs.xcode.enable = true;

  services.brewAutoupdate.enable = false;
  services.jankyborders = {
    enable = true;
    active_color = "0xffbd93f9";
    inactive_color = "0xff414550";
    width = 6.0;
    hidpi = true; # module renders as `hidpi=on`
    style = "round";
  };
  services.sketchybar.enable = false;

  home-manager.users.${config.my.user.name} = import ../../home-manager/logamma.nix;

  nix.enable = false; # Determinate uses its own daemon to manage the Nix installation

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
  system.stateVersion = 7;
}
