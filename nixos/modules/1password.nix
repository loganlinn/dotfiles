{ config, lib, pkgs, ... }:

with lib;

let

  cliCfg = config.programs._1password;
  guiCfg = config.programs._1password-gui;

in {
  config = {
    programs._1password.enable = mkDefault true;
    programs._1password-gui.enable = mkDefault true;
  } // mkIf guiCfg.enable {
    programs._1password-gui.polkitPolicyOwners = [ config.my.user.name ];
    environment.systemPackages = [ pkgs.polkit pkgs.polkit_gnome ];
    security.polkit.enable = mkDefault true;
    xdg.portal.enable = true;
  };
}
