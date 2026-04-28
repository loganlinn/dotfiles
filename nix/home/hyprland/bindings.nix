{
  config,
  lib,
  pkgs,
  ...
}:
let
  screenshotsDir = config.my.userDirs.screenshots;
in
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      # App launchers
      "SUPER, Return, exec, $terminal"
      "SUPER, space, exec, $menu"
      "SUPER SHIFT, SPACE, exec, pkill -SIGUSR1 waybar"
      "SUPER, E, exec, $fileManager"
      "SUPER, B, exec, $browser"
      "SUPER, N, exec, $terminal -e nvim"

      # Close / exit
      "SUPER, W, killactive,"
      "SUPER, Backspace, killactive,"
      "SUPER, ESCAPE, exec, hyprlock"
      "SUPER SHIFT, ESCAPE, exit,"

      # Tiling
      "SUPER, J, togglesplit,"
      "SUPER, P, pseudo,"
      "SUPER, T, togglefloating,"
      "SUPER, F, fullscreen, 0"
      "SUPER SHIFT, F, fullscreen, 1"

      # Focus
      "SUPER, left, movefocus, l"
      "SUPER, right, movefocus, r"
      "SUPER, up, movefocus, u"
      "SUPER, down, movefocus, d"

      # Swap windows
      "SUPER SHIFT, left, swapwindow, l"
      "SUPER SHIFT, right, swapwindow, r"
      "SUPER SHIFT, up, swapwindow, u"
      "SUPER SHIFT, down, swapwindow, d"

      # Workspaces 1-10
      "SUPER, 1, workspace, 1"
      "SUPER, 2, workspace, 2"
      "SUPER, 3, workspace, 3"
      "SUPER, 4, workspace, 4"
      "SUPER, 5, workspace, 5"
      "SUPER, 6, workspace, 6"
      "SUPER, 7, workspace, 7"
      "SUPER, 8, workspace, 8"
      "SUPER, 9, workspace, 9"
      "SUPER, 0, workspace, 10"

      # Move window to workspace
      "SUPER SHIFT, 1, movetoworkspace, 1"
      "SUPER SHIFT, 2, movetoworkspace, 2"
      "SUPER SHIFT, 3, movetoworkspace, 3"
      "SUPER SHIFT, 4, movetoworkspace, 4"
      "SUPER SHIFT, 5, movetoworkspace, 5"
      "SUPER SHIFT, 6, movetoworkspace, 6"
      "SUPER SHIFT, 7, movetoworkspace, 7"
      "SUPER SHIFT, 8, movetoworkspace, 8"
      "SUPER SHIFT, 9, movetoworkspace, 9"
      "SUPER SHIFT, 0, movetoworkspace, 10"

      # Workspace navigation
      "SUPER, TAB, workspace, e+1"
      "SUPER SHIFT, TAB, workspace, e-1"
      "SUPER CTRL, TAB, workspace, previous"

      # Cycle windows (alt-tab)
      "ALT, TAB, cyclenext"
      "ALT SHIFT, TAB, cyclenext, prev"
      "ALT, TAB, bringactivetotop"
      "ALT SHIFT, TAB, bringactivetotop"

      # Scratchpad
      "SUPER, S, togglespecialworkspace, magic"
      "SUPER SHIFT, S, movetoworkspace, special:magic"

      # Resize
      "SUPER, minus, resizeactive, -100 0"
      "SUPER, equal, resizeactive, 100 0"
      "SUPER SHIFT, minus, resizeactive, 0 -100"
      "SUPER SHIFT, equal, resizeactive, 0 100"

      # Scroll through workspaces
      "SUPER, mouse_down, workspace, e+1"
      "SUPER, mouse_up, workspace, e-1"

      # Screenshots (grim + slurp)
      ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      "SHIFT, Print, exec, grim - | wl-copy"
      "SUPER, Print, exec, grim -g \"$(slurp)\" ${screenshotsDir}/$(date +%Y-%m-%d_%H-%M-%S).png"

      # Color picker
      "SUPER SHIFT, Print, exec, hyprpicker -a"

      # Notification dismiss (if mako)
      "SUPER, comma, exec, makoctl dismiss"
      "SUPER SHIFT, comma, exec, makoctl dismiss --all"
    ];

    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];

    bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
