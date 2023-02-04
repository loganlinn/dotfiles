{ config, lib, pkgs, ... }:

{
  imports = [
    ../nix/modules
    ../nix/modules/desktop
    ../nix/modules/desktop/i3
  ];

  modules.desktop.i3.enable = true;
  modules.services.picom.enable = true;
  modules.services.dunst.enable = true;
  # modules.dev.enable = true;

  home.sessionVariables.BROWSER = "${config.programs.google-chrome.package}/bin/google-chrome";
  home.sessionVariables.TERMINAL = "${config.programs.kitty.package}/bin/kitty";
}