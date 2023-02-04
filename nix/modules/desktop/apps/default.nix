{ config, lib, pkgs, ... }:

{
  imports = [
    ./graphics.nix
  ];

  home.packages = with pkgs; [
    discord
    obsidian
    qalculate-gtk
    slack
    vlc
    zoom-us
  ];
}
