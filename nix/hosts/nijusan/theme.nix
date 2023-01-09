{ config, lib, pkgs, ... }:

{
  gtk = {
    font = {
      name = "Roboto";
      package = pkgs.roboto;
    };

    gtk3.bookmarks = [
      # "file://${config.xdg.userDirs.desktop}"
      "file://${config.xdg.userDirs.download}"
      "file://${config.xdg.userDirs.documents}"
      "file://${config.xdg.userDirs.pictures}"
      "file://${config.xdg.userDirs.music}"
      "file://${config.xdg.userDirs.videos}"
      # "file://${config.xdg.userDirs.publicShare}"
      # "file://${config.xdg.userDirs.templates}"
      "file://${config.home.homeDirectory}/Sync"
      "file://${config.home.homeDirectory}/.dotfiles"
      "file://${config.home.homeDirectory}/src"
      "file://${config.home.homeDirectory}/src/github.com/patch-tech"
    ];

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Catppuccin-Purple-Light-Compact";
      package = pkgs.catppuccin-gtk.override { size = "compact"; };
    };
  };

  home.pointerCursor = {
    # package = pkgs.breeze-qt5;
    # name = "Breeze";
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    gtk.enable = true;
    x11.enable = true;
  };
}
