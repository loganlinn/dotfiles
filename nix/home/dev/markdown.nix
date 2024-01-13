{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    mdsh
    glow
    nodePackages.mermaid-cli
  ];
}
