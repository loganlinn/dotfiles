{ inputs, config, lib, pkgs, ... }:

let

  cfg = config.modules.theme;

in
{

  config = lib.mkIf (cfg.active == "arc") {

    colorScheme = inputs.nix-colors.colorSchemes.nord;

    # modules.theme.colors =
    #   let onedark = (import ../colors/one-dark.nix).dark; in
    #   {
    #     inherit (onedark)
    #       black
    #       red
    #       green
    #       yellow
    #       blue
    #       magenta
    #       cyan
    #       silver
    #       grey
    #       brightred
    #       brightgreen
    #       brightyellow
    #       brightblue
    #       brightmagenta
    #       brightcyan
    #       white
    #       ;
    #     types.bg = onedark.background;
    #     types.fg = onedark.foreground;
    #   };

    gtk = {
      font = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
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

    home.pointerCursor = {
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor-Light";
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };

    programs.rofi.theme = "Arc-Dark";

  };
}
