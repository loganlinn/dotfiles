{ config, lib, pkgs, ... }:

{
  imports = [
    ./graphics.nix
  ];

  home.packages = with pkgs; [
    # discord
    obsidian
    slack
    vlc
    zoom-us
  ];

  programs.nheko.enable = false; # matrix chat app

}
