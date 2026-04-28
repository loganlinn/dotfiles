{
  config,
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = lib.mkDefault [
      "waybar"
      "mako"
      "wl-clip-persist --clipboard both"
      "systemctl --user start hyprpolkitagent"
    ];
  };
}
