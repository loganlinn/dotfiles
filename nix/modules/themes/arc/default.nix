{ config, lib, pkgs, ... }:

let

  cfg = config.modules.theme;

in
{

  config = lib.mkIf (cfg.active == "arc") {

    modules.theme.colors =
      let onedark = (import ../colors/one-dark.nix).dark; in
      {
        inherit (onedark)
          black
          red
          green
          yellow
          blue
          magenta
          cyan
          silver
          grey
          brightred
          brightgreen
          brightyellow
          brightblue
          brightmagenta
          brightcyan
          white
          ;
        types.bg = onedark.background;
        types.fg = onedark.foreground;
      };

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
