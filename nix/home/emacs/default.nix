{ inputs, config, lib, pkgs, ... }:

with lib;

let

  cfg = config.my.emacs;

in
{
  imports = [ ./doom.nix ];

  my.emacs.doom.enable = mkDefault true;

  programs.emacs = {
    enable = true;
    package = lib.mkDefault pkgs.emacs-unstable; # most recent git tag 
    extraPackages = epkgs: [ epkgs.vterm ];
  };
}
