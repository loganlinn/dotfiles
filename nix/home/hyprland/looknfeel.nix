{
  config,
  lib,
  pkgs,
  ...
}:
let
  palette = config.colorScheme.palette;
in
{
  wayland.windowManager.hyprland.settings = {
    decoration = {
      rounding = lib.mkDefault 4;

      shadow = {
        enabled = lib.mkDefault true;
        range = lib.mkDefault 2;
        render_power = lib.mkDefault 3;
        color = lib.mkDefault "rgba(1a1a1aee)";
      };

      blur = {
        enabled = lib.mkDefault true;
        size = lib.mkDefault 5;
        passes = lib.mkDefault 2;
        special = lib.mkDefault true;
        brightness = lib.mkDefault 0.60;
        contrast = lib.mkDefault 0.75;
        vibrancy = lib.mkDefault 0.1696;
      };
    };

    group = {
      "col.border_active" = lib.mkDefault "rgba(${palette.base0D}aa)";
      "col.border_inactive" = lib.mkDefault "rgba(${palette.base03}aa)";
      "col.border_locked_active" = lib.mkDefault (-1);
      "col.border_locked_inactive" = lib.mkDefault (-1);

      groupbar = {
        font_size = lib.mkDefault 12;
        font_family = lib.mkDefault config.my.fonts.mono.name;
        font_weight_active = lib.mkDefault "ultraheavy";
        font_weight_inactive = lib.mkDefault "normal";

        indicator_height = lib.mkDefault 0;
        indicator_gap = lib.mkDefault 5;
        height = lib.mkDefault 22;
        gaps_in = lib.mkDefault 5;
        gaps_out = lib.mkDefault 0;

        text_color = lib.mkDefault "rgb(ffffff)";
        text_color_inactive = lib.mkDefault "rgba(ffffff90)";
        "col.active" = lib.mkDefault "rgba(00000040)";
        "col.inactive" = lib.mkDefault "rgba(00000020)";

        gradients = lib.mkDefault true;
        gradient_rounding = lib.mkDefault 0;
        gradient_round_only_edges = lib.mkDefault false;
      };
    };

    animations = {
      enabled = lib.mkDefault true;

      bezier = lib.mkDefault [
        "easeOutQuint, 0.23, 1, 0.32, 1"
        "easeInOutCubic, 0.65, 0.05, 0.36, 1"
        "linear, 0, 0, 1, 1"
        "almostLinear, 0.5, 0.5, 0.75, 1.0"
        "quick, 0.15, 0, 0.1, 1"
      ];

      animation = lib.mkDefault [
        "global, 1, 10, default"
        "border, 1, 5.39, easeOutQuint"
        "windows, 1, 4.79, easeOutQuint"
        "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
        "windowsOut, 1, 1.49, linear, popin 87%"
        "fadeIn, 1, 1.73, almostLinear"
        "fadeOut, 1, 1.46, almostLinear"
        "fade, 1, 3.03, quick"
        "layers, 1, 3.81, easeOutQuint"
        "layersIn, 1, 4, easeOutQuint, fade"
        "layersOut, 1, 1.5, linear, fade"
        "fadeLayersIn, 1, 1.79, almostLinear"
        "fadeLayersOut, 1, 1.39, almostLinear"
        "workspaces, 0, 0, ease"
        "specialWorkspace, 1, 4, easeOutQuint, slidevert"
      ];
    };
  };
}
