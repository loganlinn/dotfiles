{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = lib.mkDefault "us";
      kb_options = lib.mkDefault "ctrl:nocaps";
      repeat_rate = lib.mkDefault 40;
      repeat_delay = lib.mkDefault 440;
      follow_mouse = lib.mkDefault 1;
      sensitivity = lib.mkDefault 0;
      touchpad = {
        natural_scroll = lib.mkDefault false;
      };
    };

    gestures = {
      workspace_swipe = lib.mkDefault false;
    };
  };
}
