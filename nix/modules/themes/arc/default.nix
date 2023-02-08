{ config, lib, pkgs, ... }:

let

  cfg = config.modules.theme;

in
{

  config = lib.mkIf (cfg.active == "arc") {

    gtk = {
      font = {
        package = pkgs.open-sans;
        name = "Open Sans";
      };

      theme = {
        name = "Arc-Dark";
        package = pkgs.arc-theme;
      };

      iconTheme = {
        package = pkgs.arc-icon-theme;
        name = "Arc";
      };
    };

    programs.rofi.theme = "Arc-Dark";

  };
}
