{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ../../home/common.nix
    ../../home/dev
    ../../home/emacs.nix
    ../../home/fonts.nix
    ../../home/jetbrains/idea.nix
    ../../home/kitty
    ../../home/mpv.nix
    ../../home/nnn.nix
    ../../home/polybar
    ../../home/pretty.nix
    ../../home/sync.nix
    ../../home/thunar.nix
    ../../home/tray.nix
    ../../home/urxvt.nix
    ../../home/vpn.nix
    ../../home/vscode.nix
    ../../home/xdg.nix
    ../../home/zsh
    ../../modules/services/dunst.nix
    ../../modules/services/picom.nix
    ../../modules/themes
    ./apps
    ./rofi
    ./theme.nix
  ];

  config = {

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
      discord
      dmenu
      epick
      font-manager
      google-cloud-sdk
      gtk3
      hacksaw
      inkscape
      libnotify
      obsidian
      pango
      pavucontrol
      ponymix
      qalculate-gtk
      shotgun
      slack
      trash-cli
      vlc
      xclip
      xorg.xev
      xorg.xkill
      xorg.xprop
      zoom-us
    ];

  };
}
