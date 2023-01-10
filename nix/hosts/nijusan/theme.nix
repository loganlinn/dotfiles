{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    open-sans
    font-awesome
    siji # iconic bitmap font
    paper-icon-theme # for rofi
  ];

  home.pointerCursor = {
    # package = pkgs.dracula-theme;
    # name = "Dracula-cursors";
    #
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    #
    # package = pkgs.breeze-qt5;
    # name = "Breeze";
    #
    # package = pkgs.bibata-cursors;
    # name = "Bibata-Modern-Classic";
    #
    x11.enable = true;
    gtk.enable = true;
  };

  # xresources.extraConfig = builtins.readFile (
  #   pkgs.fetchFromGitHub {
  #     owner = "dracula";
  #     repo = "xresources";
  #     rev = "539ef24e9b0c5498a82d59bfa2bad9b618d832a3";
  #     hash = "sha256-6fltsAluqOqYIh2NX0I/LC3WCWkb9Fn8PH6LNLBQbrY=";
  #   }
  #   + "/Xresources"
  # );
  xresources.extraConfig = builtins.readFile (pkgs.fetchFromGitHub {
      owner = "selloween";
      repo = "arc-theme-xresources";
      rev = "d1d9ccceac4e778cab58292637b0b48927756381";
      hash = "sha256-t+GpXGmSXe6Q5eDemNlEMk2cLgUh8i5kxZ1f7bkSyG8=";
    }
    + "/Xresources");

  gtk.enable = true;
  gtk.font = {
    package = pkgs.open-sans;
    name = "Open Sans";
  };
  gtk.theme = {
    # name = "Dracula";
    # package = pkgs.dracula-theme;
    name = "Arc-Dark";
    package = pkgs.arc-theme;
    # name = "Catppuccin-Purple-Dark-xhdpi";
    # package = pkgs.catppuccin-gtk.override { size = "compact"; };
  };
  # TODO package https://github.com/m4thewz/dracula-icons
  gtk.iconTheme = {
    package = pkgs.arc-icon-theme;
    name = "Arc";
  };
  gtk.gtk3.bookmarks = mkOptionDefault [
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
  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  # Workaround for apps that use libadwaita which does locate GTK settings via XDG.
  # https://www.reddit.com/r/swaywm/comments/qodk20/gtk4_theming_not_working_how_do_i_configure_it/hzrv6gr/?context=3
  home.sessionVariables.GTK_THEME = config.gtk.theme.name;

  qt.platformTheme = "gtk";

  programs.rofi.theme = "Arc-Dark";
  # programs.rofi.theme = pkgs.fetchFromGitHub {
  #   owner = "dracula";
  #   repo = "rofi";
  #   rev = "090a990c8dc306e100e73cece82dc761f3f0130c";
  #   hash = "sha256-raoJ3ndKtpEpsN3yN4tMt5Kn1PrqVzlakeCZMETmItw=";
  # }
  # + "/theme/config1.rasi";
  programs.rofi.font = "DejaVu Sans Mono 14";
  services.dunst.iconTheme = config.gtk.iconTheme;

  services.xsettingsd = {
    enable = true;
    settings = with config; {
      # When running, most GNOME/GTK+ applications prefer those settings instead of *.ini files
      "Net/IconThemeName" = config.gtk.iconTheme.name;
      "Net/ThemeName" = config.gtk.theme.name;
      "Gtk/CursorThemeName" = config.xsession.pointerCursor.name;
    };
  };
}
