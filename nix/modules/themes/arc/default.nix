{ config, lib, pkgs, ... }:

let

  cfg = config.modules.theme;

in
{

  config = lib.mkIf (cfg.active == "arc") {

    xresources.extraConfig = builtins.readFile (pkgs.fetchFromGitHub
      {
        owner = "selloween";
        repo = "arc-theme-xresources";
        rev = "d1d9ccceac4e778cab58292637b0b48927756381";
        hash = "sha256-t+GpXGmSXe6Q5eDemNlEMk2cLgUh8i5kxZ1f7bkSyG8=";
      }
    + "/Xresources");

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
    programs.rofi.font = "Noto 16";

    # https://github.com/aristocratos/btop/tree/main/themes
    programs.btop.settings.color_theme = "OneDark";

    home.pointerCursor = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

  };
}
