{ config
, lib
, pkgs
, ...
}:
with lib; {
  imports = [
    ../../modules/themes
    ../../modules/services/window-managers/i3
    ../../modules/services/picom.nix
    ../../modules/services/dunst.nix
  ];

  modules.services.picom.enable = true;
  modules.services.dunst.enable = true;

  xsession.enable = true;
  xsession.windowManager.i3.enable = true;

  programs.feh.enable = true;

  services.clipmenu = {
    enable = true;
    launcher = getExe config.programs.rofi.package;
  };

  services.flameshot = {
    enable = true;
  };

  home.packages = with pkgs; [
    dmenu
    epick
    hacksaw
    pavucontrol
    python3Packages.i3ipc
    shotgun
  ];
}
