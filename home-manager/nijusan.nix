{ config, lib, pkgs, ... }:

{
  imports = [
    ../nix
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
    ../nix/modules/programs/eww
    ../nix/modules/programs/the-way
    ../nix/modules/services
    ../nix/modules/spellcheck.nix
    ../nix/modules/fonts.nix
    ../nix/modules/desktop
    ../nix/modules/desktop/browsers
    ../nix/modules/desktop/i3
  ];

  modules.fonts.enable = true;

  modules.spellcheck.enable = true;

  modules.desktop.i3.enable = true;

  modules.theme = {
    active = "arc";
  };

  programs.rofi.enable = true;

  programs.the-way = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  services.dunst.enable = true;

  services.polybar.enable = true;

  services.picom.enable = true;

  # TODO define option for default browser
  home.sessionVariables.BROWSER = "${lib.getExe config.programs.google-chrome.package}";

  gtk.enable = true;

  home.packages = with pkgs; [
    btrfs-progs
    google-cloud-sdk
    # nemo
  ];

  home.stateVersion = "22.11";
}
