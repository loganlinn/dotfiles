{ config, lib, pkgs, nix-colors, ... }:

{
  imports = [
    nix-colors.homeManagerModule
    ../nix/home/common.nix
    ../nix/home/dev
    ../nix/home/pretty.nix
  ];

  colorScheme = nix-colors.colorSchemes.doom-one;

  home.stateVersion = "22.11";
}
