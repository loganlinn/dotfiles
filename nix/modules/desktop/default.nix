{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.modules.desktop;
in {
  imports = [
    ../../home/polybar
    ../../home/rofi
    ../../home/thunar.nix
    ../../home/xdg.nix
    ../themes
    ./apps
    ./browsers
    ./picom.nix
    ./syncthing.nix
    ./tray.nix
  ];

  options.modules.desktop = with types; {
    bookmarks = mkOption {
      type = listOf str;
      default = [
        "file://${config.xdg.userDirs.download}"
        "file://${config.xdg.userDirs.documents}"
        "file://${config.xdg.userDirs.pictures}"
        "file://${config.xdg.userDirs.music}"
        "file://${config.xdg.userDirs.videos}"
        "file://${config.xdg.configHome}"
        "file://${config.xdg.dataHome}"
        "file://${config.home.homeDirectory}/Sync"
        "file://${config.home.homeDirectory}/.dotfiles"
        "file://${config.home.homeDirectory}/src"
        "file://${config.home.homeDirectory}/src/github.com/patch-tech"
        "davs://myfiles.fastmail.com/"
      ];
    };
  };

  config = {
    modules.programs.eww.enable = false;
    programs.eww.enable = false;

    programs.feh.enable = true;

    services.playerctld.enable = true;

    services.flameshot.enable = true;

    services.network-manager-applet.enable = true;

    gtk.gtk3.bookmarks = cfg.bookmarks;

    home.packages = with pkgs;
      [
        arandr
        gtk3
        desktop-file-utils # update-desktop-database
        libnotify
        pango
        networkmanagerapplet # nm-connection-editor

        # (conky.override {
        #   x11Support = true;
        #   curlSupport = true;
        #   nvidiaSupport = lib.pathExists "/run/current-system/sw/bin/nvidia-smi";
        #   pulseSupport = true;
        # })

        font-manager
        fontpreview
        gcolor3
        gpick

        hacksaw # Lightweight selection tool for usage in screenshot scripts etc
        shotgun # Minimal X screenshot utility

        pavucontrol # PulseAudio Volume Control
        ponymix # CLI PulseAudio Volume Control
        ncpamixer # An ncurses mixer for PulseAudio inspired by pavucontrol
        playerctl

        libqalculate
        qalculate-gtk

        vlc
        nsxiv # simple image viewer
      ]
      ++ [
        # x11
        xdotool # Fake keyboard/mouse input, window management, etc
        xscreensaver

        xorg.xev
        xorg.xkill
        xorg.xprop
        xorg.xwininfo
        xorg.xrandr
        xorg.xkbevd
        xorg.xmodmap
        xorg.xdpyinfo
      ]
      ++ [
        obsidian
        slack
        inkscape
      ];
  };
}
