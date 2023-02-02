{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) getExe;
in
{
  imports = [
    ../../home/3d-graphics.nix
    ../../home/browser.nix
    ../../home/common.nix
    ../../home/dev
    ../../home/emacs.nix
    ../../home/fonts.nix
    ../../home/git.nix
    ../../home/jetbrains/idea.nix
    ../../home/kitty
    ../../home/mpv.nix
    ../../home/nnn.nix
    ../../home/polybar
    ../../home/pretty.nix
    ../../home/sync.nix
    ../../home/tray.nix
    ../../home/urxvt.nix
    ../../home/vpn.nix
    ../../home/vscode.nix
    ../../home/xdg.nix
    ../../home/zsh
    ../../modules/programs/eww
    ../../modules/services/dunst.nix
    ../../modules/services/picom.nix
    ../../modules/services/window-managers/i3
    ../../modules/themes
    ./theme.nix
  ];

  modules.services.picom.enable = true;
  modules.services.dunst.enable = true;
  modules.programs.eww.enable = true;

  xsession = {
    enable = true;
    windowManager.i3.enable = true;
  };

  programs.feh.enable = true;

  services.clipmenu = {
    enable = true;
    launcher = getExe config.programs.rofi.package;
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

  home.username = "logan";
  home.homeDirectory = "/home/logan";
  home.packages = with pkgs; [
    conky
    dmenu
    epick
    font-manager
    google-cloud-sdk
    hacksaw
    inkscape
    libnotify
    obsidian
    pango
    pavucontrol
    ponymix
    python3
    qalculate-gtk
    shotgun
    slack
    trash-cli
    vlc
    xorg.xev
    xorg.xkill
    xorg.xprop
    zoom-us
  ];
  home.stateVersion = "22.11";
  home.enableDebugInfo = false;
}
