{ config, lib, pkgs, nix-colors, ... }:

{
  imports = [
    nix-colors.homeManagerModule
    ../nix/modules/fonts.nix
    ../nix/home/common.nix
    ../nix/home/dev
    ../nix/home/pretty.nix
  ];

  colorScheme = nix-colors.colorSchemes.doom-one;

  modules.fonts.enable = true;

  home.stateVersion = "22.11";
}
