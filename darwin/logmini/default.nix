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
    ../modules/kitty
    ../modules/aerospace
    ../modules/emacs-plus
    ../modules/hammerspoon
    ../modules/xcode.nix
    ./homebrew.nix
  ];

  environment.etc."nix/nix.custom.conf".text = settingsToConf config.my.nix.settings;

  networking.localHostName = "logmini";

  my.user.uid = 501;
  ids.gids.nixbld = 30000;

  modules.kitty.enable = true;

  programs.aerospace.enable = true;
  programs.emacs-plus.enable = true;
  programs.hammerspoon.enable = true;
  programs.xcode.enable = true;

  home-manager.users.${config.my.user.name} = import ../../home-manager/logmini.nix;

  nix.enable = false; # Determinate uses its own daemon to manage the Nix installation

  system.stateVersion = 7;
}
