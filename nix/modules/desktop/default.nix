{ config, lib, pkgs, ... }:

let
  cfg = config.modules.desktop;
in
{
  imports = [
    ../../home/polybar
    ../../home/rofi
    ../../home/xdg.nix
    ../themes
    ./apps
    ./browsers
    ./tray.nix
  ];

  config = {
    programs.feh.enable = true;
    programs.zathura.enable = true; # Document viewer

    services.playerctld.enable = true;
    services.flameshot.enable = true;
    services.network-manager-applet.enable = true;

    # gtk.gtk3.bookmarks = mkIf (!builtins.pathExists "${config.xdg.configHome}/gtk-3.0/bookmarks") [
    #     "file://${config.xdg.userDirs.download}"
    #     "file://${config.xdg.userDirs.documents}"
    #     "file://${config.home.homeDirectory}/Sync"
    #     "file://${config.xdg.userDirs.pictures}"
    #     "file://${config.xdg.userDirs.music}"
    #     "file://${config.xdg.userDirs.videos}"
    #     "file://${config.home.homeDirectory}/src"
    #     # "file:///run/current-system/sw current-system"
    #     # "davs://myfiles.fastmail.com/ Fastmail Files"
    # ];

    gtk.enable = true;

    home.packages = with pkgs; [
      desktop-file-utils # update-desktop-database
      font-manager
      fontpreview
      gcolor3
      gpick
      gtk3
      hacksaw # Lightweight selection tool for usage in screenshot scripts etc
      libnotify
      ncpamixer # An ncurses mixer for PulseAudio inspired by pavucontrol
      networkmanagerapplet # nm-connection-editor
      nsxiv # simple image viewer
      pango
      pavucontrol # PulseAudio Volume Control
      playerctl
      ponymix # CLI PulseAudio Volume Control
      shotgun # Minimal X screenshot utility
      vlc
    ];
  };
}
