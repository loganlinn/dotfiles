{ config, lib, pkgs, ... }:

{
    imports = [
      ../nix/modules/fonts.nix
      ../nix/home/common.nix
      ../nix/home/dev
      ../nix/home/pretty.nix
    ];

    modules.fonts.enable = true;

    home.stateVersion = "22.11";
}
