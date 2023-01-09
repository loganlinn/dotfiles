{ config, lib, pkgs, ... }:
let
  inherit (lib) getExe;
in {
  imports = [
    ../../home/3d-graphics.nix
    ../../home/browser.nix
    ../../home/common.nix
    ../../home/dev.nix
    ../../home/dunst
    ../../home/emacs.nix
    ../../home/fonts.nix
    ../../home/git.nix
    ../../home/i3
    ../../home/kitty
    ../../home/nnn.nix
    ../../home/pretty.nix
    ../../home/sync.nix
    ../../home/tray.nix
    ../../home/vpn.nix
    ../../home/vscode.nix
    ../../home/xdg.nix
    ../../home/zsh.nix
    ./desktop.nix
    ./theme.nix
  ];

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
    ark
    jetbrains.idea-community
    libnotify
    obsidian
    pango
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
