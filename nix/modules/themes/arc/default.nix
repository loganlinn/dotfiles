{ config, lib, pkgs, ... }:

let

  cfg = config.modules.theme;

in
{
  config = lib.mkIf (cfg.active == "arc") {
    gtk.enable = true;
    gtk.theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    gtk.iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    home.pointerCursor = {
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor-Light";
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
  };
}
