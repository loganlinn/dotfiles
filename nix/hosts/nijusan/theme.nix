{ config, lib, pkgs, ... }:

let
  bookmarks = [
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
in {
  home = {
    packages = with pkgs; [
      font-awesome_5
      hicolor-icon-theme
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    pointerCursor = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 32;

      # package = pkgs.breeze-qt5;
      # name = "Breeze";

      # package = pkgs.bibata-cursors;
      # name = "Bibata-Modern-Classic";

      x11.enable = true;
      gtk.enable = true;
    };

    # Application using libadwaita are **not** respecting config files *sigh*
    # https://www.reddit.com/r/swaywm/comments/qodk20/gtk4_theming_not_working_how_do_i_configure_it/hzrv6gr/?context=3
    sessionVariables.GTK_THEME = config.gtk.theme.name;
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
      # name = "Catppuccin-Purple-Dark-xhdpi";
      # package = pkgs.catppuccin-gtk.override { size = "compact"; };
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.bookmarks = bookmarks;
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  services.xsettingsd = {
    enable = true;
    settings = with config; {
      # When running, most GNOME/GTK+ applications prefer those settings
      # instead of *.ini files
      "Net/IconThemeName" = gtk.iconTheme.name;
      "Net/ThemeName" = gtk.theme.name;
      "Gtk/CursorThemeName" = xsession.pointerCursor.name;
    } // lib.optionalAttrs (super ? fonts.fontconfig) {
      # Applications like Java/Wine doesn't use Fontconfig settings,
      # but uses it from here
      "Xft/Hinting" = super.fonts.fontconfig.hinting.enable;
      "Xft/HintStyle" = super.fonts.fontconfig.hinting.style;
      "Xft/Antialias" = super.fonts.fontconfig.antialias;
      "Xft/RGBA" = super.fonts.fontconfig.subpixel.lcdfilter;
    };
  };

}
