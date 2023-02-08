{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.modules.services.picom;

in
{
  options.modules.services.picom = {
    enable = mkEnableOption "Picom X11 compositor";
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      opacityRules = [
        # "100:class_g = 'firefox'"
        # "100:class_g = 'google-chrome'"
        "100:class_g = 'VirtualBox Machine'"
        # Art/image programs where we need fidelity
        "100:class_g = 'Blender'"
        "100:class_g = 'Gimp'"
        "100:class_g = 'Inkscape'"
        "100:class_g = 'aseprite'"
        "100:class_g = 'krita'"
        "100:class_g = 'feh'"
        "100:class_g = 'mpv'"
        "100:class_g = 'Rofi'"
        "100:class_g = 'Peek'"
        "99:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
      ];
      shadow = true;
      fade = false;
      shadowExclude = [
        "!I3_FLOATING_WINDOW@:c && !class_g = 'Rofi' && !class_g = 'dmenu' && !class_g = 'Dunst'"
      ];
      settings = {
        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'Rofi'"
          "_GTK_FRAME_EXTENTS@:c"
        ];
        # Unredirect all windows if a full-screen opaque window is detected, to
        # maximize performance for full-screen windows. Known to cause
        # flickering when redirecting/unredirecting windows.
        unredir-if-possible = true;
        # GLX backend: Avoid using stencil buffer, useful if you don't have a
        # stencil buffer. Might cause incorrect opacity when rendering
        # transparent content (but never practically happened) and may not work
        # with blur-background. My tests show a 15% performance boost.
        # Recommended.
        glx-no-stencil = true;
        # Use X Sync fence to sync clients' draw calls, to make sure all draw
        # calls are finished before picom starts drawing. Needed on
        # nvidia-drivers with GLX backend for some users.
        xrender-sync-fence = true;
      };
    };
  };
}
