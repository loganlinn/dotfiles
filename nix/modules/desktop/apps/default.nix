{ config, lib, pkgs, ... }:

{
  imports = [
    ./graphics.nix
  ];

  home.packages = with pkgs; [
    # discord
    # obsidian ## causes error due to electron package EOL (insecure)
    slack
    vlc
    zoom-us
  ];

  programs.nheko.enable = false; # matrix chat app
  

}
