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
    ../../home/fonts.nix
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
        xdotool
        conky
        desktop-file-utils # update-desktop-database
        dmenu
        epick
        font-manager
        gtk3
        hacksaw
        libnotify
        obsidian
        pango
        pavucontrol
        ponymix
        libqalculate
        qalculate-gtk
        shotgun
        slack
        trash-cli
        vlc
        xclip
        xorg.xev
        xorg.xkill
        xorg.xprop
        xorg.xwininfo
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
