{ config, lib, pkgs, ... }:

{
    imports = [
      ../nix/modules/fonts.nix
      ../nix/home/common.nix
      ../nix/home/dev
      ../nix/home/pretty.nix
      ../nix/home/zsh
    ];

    modules.fonts.enable = true;

    home.stateVersion = "22.11";
}
