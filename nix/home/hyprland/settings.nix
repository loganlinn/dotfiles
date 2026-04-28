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
    "$mod" = "SUPER";
    "$terminal" = lib.mkDefault "ghostty";
    "$fileManager" = lib.mkDefault "nautilus --new-window";
    "$browser" = lib.mkDefault "google-chrome-stable";
    "$menu" = lib.mkDefault "wofi --show drun --sort-order=alphabetical";

    monitor = lib.mkDefault [",preferred,auto,1"];

    general = {
      layout = lib.mkDefault "dwindle";
      border_size = lib.mkDefault 2;
      gaps_in = lib.mkDefault 5;
      gaps_out = lib.mkDefault 10;
      "col.active_border" = lib.mkDefault "rgba(${palette.base0D}aa)";
      "col.inactive_border" = lib.mkDefault "rgba(${palette.base03}aa)";
      resize_on_border = lib.mkDefault false;
      allow_tearing = lib.mkDefault false;
    };

    dwindle = {
      pseudotile = lib.mkDefault true;
      preserve_split = lib.mkDefault true;
      force_split = lib.mkDefault 2;
    };

    master = {
      new_status = lib.mkDefault "master";
    };

    misc = {
      force_default_wallpaper = lib.mkDefault 0;
      disable_hyprland_logo = lib.mkDefault true;
      disable_splash_rendering = lib.mkDefault true;
      disable_scale_notification = lib.mkDefault true;
      focus_on_activate = lib.mkDefault true;
      mouse_move_enables_dpms = lib.mkDefault true;
      key_press_enables_dpms = lib.mkDefault true;
    };

    cursor = {
      no_hardware_cursors = lib.mkDefault true;
      hide_on_key_press = lib.mkDefault true;
    };

    binds = {
      hide_special_on_workspace_change = lib.mkDefault true;
    };

    xwayland = {
      force_zero_scaling = lib.mkDefault true;
    };

    ecosystem = {
      no_update_news = lib.mkDefault true;
    };
  };
}
