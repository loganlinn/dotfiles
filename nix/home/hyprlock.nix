{
  config,
  lib,
  inputs',
  ...
}: let
  palette = config.colorScheme.palette;
in {
  programs.hyprlock = {
    enable = lib.mkDefault true;
    package = inputs'.hyprlock.packages.hyprlock;
    settings = {
      general = {
        grace = 5;
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "650, 100";
          position = "0, 0";
          halign = "center";
          valign = "center";

          outline_thickness = 4;
          outer_color = "rgb(${palette.base05})";
          inner_color = "rgb(${palette.base01})";
          font_color = "rgb(${palette.base05})";
          check_color = "rgb(${palette.base0B})";
          fail_color = "rgb(${palette.base08})";

          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          fade_on_empty = false;
          placeholder_text = "Enter Password";
          fail_text = "<i>$FAIL ($ATTEMPTS)</i>";
          rounding = 0;
          shadow_passes = 0;
        }
      ];
    };
  };
}
