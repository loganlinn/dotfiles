{ config
, lib
, pkgs
, ...
}:

with lib;

{
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
  ];

  environment.systemPackages = with pkgs; [
    xfce.xfce4-volumed-pulse
    # one of the following needed for thunar-archive-plugin
    # see: https://docs.xfce.org/xfce/thunar/archive
    xarchiver
    # gnome.file-roller # Gnome
    # libsForQt5.ark    # KDE
    # mate.engrampa     # MATE
  ];

  services.tumbler.enable = true; # thunar thumbnail support for images

  # services.gvfs.enable = true; # thunar mount, trash, and other functionalities
}
