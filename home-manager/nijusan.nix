{ config, lib, pkgs, ... }:

{
  imports = [
    ../nix/home/common.nix
    ../nix/home/dev # TODO module
    ../nix/home/emacs.nix # TODO module
    ../nix/home/kitty
    ../nix/home/mpv.nix
    ../nix/home/nnn.nix
    ../nix/home/pretty.nix
    ../nix/home/sync.nix
    ../nix/home/urxvt.nix
    ../nix/home/vpn.nix
    ../nix/home/vscode.nix
    ../nix/home/zsh
    ../nix/modules
    ../nix/modules/desktop
    ../nix/modules/desktop/browsers
    ../nix/modules/desktop/i3
  ];

  # matrix chat app
  programs.nheko.enable = true;

  modules.desktop.i3.enable = true;
  modules.services.picom.enable = true;
  modules.services.dunst.enable = true;
  # modules.dev.enable = true;

  # TODO define option for default browser
  home.sessionVariables.BROWSER = "${lib.getExe config.programs.google-chrome.package}";
  home.sessionVariables.TERMINAL = "${config.programs.kitty.package}/bin/kitty";


  home.packages = with pkgs; [
    google-cloud-sdk
  ];
}
