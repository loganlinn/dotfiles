{ config
, options
, lib
, pkgs
, ...
}:

let

  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types;

  cfg = config.modules.desktop;

in
{

  imports = [
    ../../home/polybar
    ../../home/thunar.nix
    ../../home/tray.nix
    ../../home/xdg.nix
    ../themes
    ./apps
    ./rofi
    ./picom.nix
    ./notifications/dunst.nix
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
      ];
    };

    media.graphics.enable = mkEnableOption "Graphics editing";

  };

  config = mkMerge [
    {
      programs.eww.enable = true;

      programs.feh.enable = true;

      modules.programs.eww.enable = true;

      services.clipmenu = {
        enable = true;
        launcher = lib.getExe config.programs.rofi.package;
      };

      services.flameshot.enable = true;

      services.network-manager-applet.enable = true;

      # needs ./tray.nix
      services.syncthing = {
        enable = true;
        tray = {
          enable = true;
          package = pkgs.syncthingtray.override {
            webviewSupport = true;
            jsSupport = true;
            plasmoidSupport = false;
            kioPluginSupport = false;
          };
          command = "syncthingtray --wait";
        };
      };

      home.packages = with pkgs; [
        arandr
        gtk3
        desktop-file-utils # update-desktop-database
        libnotify
        pango

        (conky.override {
          x11Support = true;
          curlSupport = true;
          nvidiaSupport = lib.pathExists "/run/current-system/sw/bin/nvidia-smi";
          pulseSupport = true;
        })

        font-manager
        fontpreview
        gcolor3
        epick # Simple color picker that lets the user create harmonic palettes with ease

        hacksaw # Lightweight selection tool for usage in screenshot scripts etc
        shotgun # Minimal X screenshot utility

        pavucontrol # PulseAudio Volume Control
        ponymix # CLI PulseAudio Volume Control
        ncpamixer # An ncurses mixer for PulseAudio inspired by pavucontrol

        libqalculate
        qalculate-gtk

        vlc
      ] ++ [

        # x11
        xdotool # Fake keyboard/mouse input, window management, etc
        xclip
        xscreensaver

        xorg.xev # Event viewer
        xorg.xkill
        xorg.xprop
        xorg.xwininfo
        xorg.xrandr
        xorg.xkbevd
        xorg.xmodmap

        nsxiv # simple image viewer
      ] ++ [

        obsidian
        slack

      ];

      gtk.gtk3.bookmarks = cfg.bookmarks;

      # # Try really hard to get QT to respect my GTK theme.
      # env.GTK_DATA_PREFIX = [ "${config.system.path}" ];
      # env.QT_QPA_PLATFORMTHEME = "gnome";
      # env.QT_STYLE_OVERRIDE = "kvantum";

    }
    (mkIf cfg.media.graphics.enable {
      home.packages = with pkgs; [
        inkscape
      ];
    })
  ];
}
