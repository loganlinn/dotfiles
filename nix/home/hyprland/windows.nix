{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "suppressevent maximize, class:.*"

      # Default opacity
      "tag +default-opacity, class:.*"
      "opacity 0.97 0.9, tag:default-opacity"

      # Browser: full opacity for video, slight for browsing
      "opacity 1 1, class:^(chromium|google-chrome|google-chrome-stable)$, title:.*Youtube.*"
      "opacity 1 0.97, class:^(chromium|google-chrome|google-chrome-stable)$"
      "opacity 0.97 0.9, initialClass:^(chrome-.*-Default)$"
      "opacity 1 1, initialClass:^(chrome-youtube.*-Default)$"

      # Full opacity for media/games
      "opacity 1 1, class:^(zoom|vlc|org.kde.kdenlive|com.obsproject.Studio)$"
      "opacity 1 1, class:^(com.libretro.RetroArch|steam)$"

      # Tile chromium (--app mode bug)
      "tile, class:^(chromium)$"
      "tile, class:^(google-chrome)$"
      "tile, class:^(google-chrome-stable)$"

      # Float settings dialogs
      "float, class:^(org.pulseaudio.pavucontrol|blueberry.py)$"
      "float, class:^(nm-connection-editor)$"
      "float, title:(Open File)"
      "float, title:(Save File)"
      "float, class:(xdg-desktop-portal-gtk)"

      # Float Steam, fullscreen RetroArch
      "float, class:^(steam)$"
      "fullscreen, class:^(com.libretro.RetroArch)$"

      # Fix XWayland drag issues
      "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0"
    ];

    layerrule = [
      "blur, wofi"
      "blur, waybar"
    ];
  };
}
