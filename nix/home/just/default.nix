{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.just ];
  home.shellAliases.".j" = "env -C ~/.dotfiles just";
}
