{ config, lib, pkgs, ... }:

let

  cfg = config.modules.theme;

in
{

  # TODO borrow more from https://github.com/hlissner/dotfiles/blob/master/modules/themes/alucard/default.nix#L12
  config = lib.mkIf (cfg.active == "dracula") {

    gtk.theme.name = "Dracula";
    gtk.theme.package = pkgs.dracula-theme;

    # TODO package https://github.com/m4thewz/dracula-icons

    xresources.extraConfig = builtins.readFile (pkgs.fetchFromGitHub
      {
        owner = "dracula";
        repo = "xresources";
        rev = "539ef24e9b0c5498a82d59bfa2bad9b618d832a3";
        hash = "sha256-6fltsAluqOqYIh2NX0I/LC3WCWkb9Fn8PH6LNLBQbrY=";
      }
    + "/Xresources");

    programs.rofi.theme = (pkgs.fetchFromGitHub
      {
        owner = "dracula";
        repo = "rofi";
        rev = "090a990c8dc306e100e73cece82dc761f3f0130c";
        hash = "sha256-raoJ3ndKtpEpsN3yN4tMt5Kn1PrqVzlakeCZMETmItw=";
      }
    + "/theme/config1.rasi");
  };


}
