{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.my.emacs;

in
{
  imports = [ ./doom.nix ];

  my.emacs.doom.enable = mkDefault true;

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-unstable.override {
      withGTK3 = true;
      withXwidgets = true;
      withSQLite3 = true;
    };
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  services.emacs = {
    enable = false;
    startWithUserSession = true;
    defaultEditor = false;
  };

  home.shellAliases = {
    et = "emacs -nw";
    emacs-eval = "emacsclient -n --eval";
    erepl = "rlwrap doom run --repl";
  };
}
