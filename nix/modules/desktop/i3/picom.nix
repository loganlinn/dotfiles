{ config, lib, pkgs, ... }:

{
  services.picom = {
    backend = "glx";
    vSync = true;
    activeOpacity = 1.0;
    opacityRules = [
      "0:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_HIDDEN'"
      "99:class_g = 'Pale moon' && !_NET_WM_STATE@:32a"
      "99:class_g = 'mpv' && !_NET_WM_STATE@:32a"
      "99:I3_FLOATING_WINDOW@:c"
      "99:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
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
    ];
    shadow = true;
    shadowOffsets = [ (-15) (-15) ];
    shadowOpacity = 0.75;
    shadowExclude = [
      "_GTK_FRAME_EXTENTS@:c"
      "_PICOM_SHADOW@:32c = 0"
      "_NET_WM_WINDOW_TYPE:a = '_NET_WM_WINDOW_TYPE_NOTIFICATION'"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_STICKY'"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
      "window_type = 'combo'"
      "window_type = 'desktop'"
      "window_type = 'dnd'"
      "window_type = 'dock'"
      "window_type = 'dropdown_menu'"
      "window_type = 'menu'"
      "window_type = 'notification'"
      "window_type = 'popup_menu'"
      "window_type = 'splash'"
      "window_type = 'toolbar'"
      "window_type = 'utility'"
      "class_g = 'i3-frame'"
      "class_g = 'Conky'"
      "class_g = 'slop'"
      "class_g = 'i3-frame'"
      "!I3_FLOATING_WINDOW@:c"
      # "!I3_FLOATING_WINDOW@:c && !class_g = 'Rofi' && !class_g = 'dmenu' && !class_g = 'Dunst'"
    ];
    fade = false;
    fadeDelta = 10;
    fadeSteps = [ 0.03 0.03 ];
    fadeExclude = [
      "window_type = 'combo'"
      "window_type = 'desktop'"
      "window_type = 'dock'"
      "window_type = 'dnd'"
      "window_type = 'notification'"
      "window_type = 'toolbar'"
      "window_type = 'unknown'"
      "window_type = 'utility'"
      "_PICOM_FADE@:32c = 0"
      "!I3_FLOATING_WINDOW@:c"
    ];
    settings = {
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "window_type = 'notification'"
        "window_type = 'utility'"
        "class_g = 'Polybar'"
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
}
