{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ../common.nix
    ../../nix/home/3d-graphics.nix
    ../../nix/home/browser.nix
    ../../nix/home/dev
    ../../nix/home/emacs.nix
    ../../nix/home/fonts.nix
    ../../nix/home/git.nix
    ../../nix/home/jetbrains/idea.nix
    ../../nix/home/kitty
    ../../nix/home/mpv.nix
    ../../nix/home/nnn.nix
    ../../nix/home/polybar
    ../../nix/home/pretty.nix
    ../../nix/home/sync.nix
    ../../nix/home/tray.nix
    ../../nix/home/urxvt.nix
    ../../nix/home/vpn.nix
    ../../nix/home/vscode.nix
    ../../nix/home/xdg.nix
    ../../nix/home/zsh
    ../../nix/modules/services/dunst.nix
    ../../nix/modules/services/picom.nix
    ../../nix/modules/services/window-managers/i3
    ../../nix/modules/themes
    ./theme.nix
  ];

  programs.eww.enable = true;

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
    conky
    dmenu
    discord
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
    xorg.xev
    xorg.xkill
    xorg.xprop
    zoom-us
  ];

}
