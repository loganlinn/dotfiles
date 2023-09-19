{ config, lib, pkgs, ... }:

with lib;

let
  # cfg = config.my.picom;
  # mkOpt = type: default: attrs: mkOption ({ inherit type default; } // attrs);
in {
  # options.my.picom = with types; {
  #   opacityRules = mkOpt (listOf (submodule {
  #     options = {
  #       class = mkOpt str null;
  #       opacity = mkOpt (ints.between 0 100) null;
  #     };
  #   })) [ ];
  # };

  config = {
    services.picom = {
      backend = "glx";
      vSync = true;
      activeOpacity = 1.0;
      inactiveOpacity = 1.0;
      opacityRules = [
        "0:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_HIDDEN'"
        # "80:class_g = 'kitty' && I3_FLOATING_WINDOW@:c && !focused"
        "90:I3_FLOATING_WINDOW@:c && class_g ?= 'kitty' && !focused"
        # Transparency excludes
        "100:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
        "100:class_g = 'Blender'"
        "100:class_g = 'Gimp'"
        "100:class_g = 'Inkscape'"
        "100:class_g = 'aseprite'"
        "100:class_g = 'krita'"
        "100:class_g = 'feh'"
        "100:class_g = 'mpv'"
        "100:class_g = 'Rofi'"
        "100:class_g = 'Peek'"
        "100:class_g = 'VirtualBox Machine'"
      ];
      shadow = false;
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
        "class_g = 'Firefox' && argb"
        "class_g = 'Conky'"
        "class_g = 'Kupfer'"
        "class_g = 'Synapse'"
        "class_g ?= 'notify-osd'"
        "class_g ?= 'cairo-dock'"
        "class_g ?= 'xfce4-notifyd'"
        "class_g ?= 'xfce4-power-manager'"
        "class_g = 'slop'"
        "class_g = 'i3-frame'"
        "class_g = 'qFlipper'"
        "name = 'Notification'"
        "name = 'Plank'"
        "name = 'Docky'"
        "name = 'Kupfer'"
        "name = 'xfce4-notifyd'"
        "name *= 'VLC'"
        "name *= 'compton'"
        "name *= 'Chromium'"
        "name *= 'Chrome'"

        "name = 'cpt_frame_xcb_window'" # used by zoom
        "class_g ?= 'zoom'"

        "!I3_FLOATING_WINDOW@:c"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      fade = false;
      fadeDelta = 10;
      fadeSteps = [ 3.0e-2 3.0e-2 ];
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
        use-damage = false;

        log-level = "warn";
        # log-level = "debug";

        frame-opacity = 1.0;

        # blur = {method = "gaussian"; size = 10; deviation = 5.0;};
        blur = {
          method = "dual_kawase";
          strength = 3;
        };

        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "window_type = 'notification'"
          "window_type = 'utility'"
          "class_g = 'Polybar'"
          "class_g = 'Rofi'"
          "class_g ?= 'zoom'"
          "_GTK_FRAME_EXTENTS@:c"
        ];

        # Try to detect WM windows and mark them as active.
        mark-wmwin-focused = true;

        # Mark all non-WM but override-redirect windows active (e.g. menus).
        mark-ovredir-focused = true;

        # Use EWMH _NET_WM_ACTIVE_WINDOW to determine which window is focused instead of using FocusIn/Out events.
        # Usually more reliable but depends on a EWMH-compliant WM.
        use-ewmh-active-win = true;

        # Detect rounded corners and treat them as rectangular when --shadow-ignore-shaped is on.
        detect-rounded-corners = true;

        # Detect _NET_WM_OPACITY on client windows, useful for window managers not passing _NET_WM_OPACITY of client windows to frame windows.
        # This prevents opacity being ignored for some apps.
        # For example without this enabled my xfce4-notifyd is 100% opacity no matter what.
        detect-client-opacity = true;

        # Specify refresh rate of the screen.
        # If not specified or 0, picom will try detecting this with X RandR extension.
        refresh-rate = 0;

        # Unredirect all windows if a full-screen opaque window is detected, to
        # maximize performance for full-screen windows. Known to cause
        # flickering when redirecting/unredirecting windows.
        unredir-if-possible = false;

        # Limit picom to repaint at most once every 1 / refresh_rate second to boost performance.
        # This should not be used with --vsync drm/opengl/opengl-oml as they essentially does --sw-opti's job already,
        # unless you wish to specify a lower refresh rate than the actual value.
        sw-opti = false;

        # Specify a list of conditions of windows that should always be considered focused.
        focus-exclude = [ ];

        # Use WM_TRANSIENT_FOR to group windows, and consider windows in the same group focused at the same time.
        detect-transient = true;
        # Use WM_CLIENT_LEADER to group windows, and consider windows in the same group focused at the same time.
        # WM_TRANSIENT_FOR has higher priority if --detect-transient is enabled, too.
        detect-client-leader = true;

        #################################
        #
        # GLX backend
        #
        #################################

        # GLX backend: Avoid using stencil buffer, useful if you don't have a
        # stencil buffer. Might cause incorrect opacity when rendering
        # transparent content (but never practically happened) and may not work
        # with blur-background. My tests show a 15% performance boost.
        # Recommended.
        glx-no-stencil = true;

        # GLX backend: Copy unmodified regions from front buffer instead of redrawing them all.
        # My tests with nvidia-drivers show a 10% decrease in performance when the whole screen is modified,
        # but a 20% increase when only 1/4 is.
        # My tests on nouveau show terrible slowdown.
        glx-copy-from-front = false;

        # GLX backend: Use MESA_copy_sub_buffer to do partial screen update.
        # My tests on nouveau shows a 200% performance boost when only 1/4 of the screen is updated.
        # May break VSync and is not available on some drivers.
        # Overrides --glx-copy-from-front.
        # glx-use-copysubbuffermesa = true;

        # GLX backend: Avoid rebinding pixmap on window damage.
        # Probably could improve performance on rapid window content changes, but is known to break things on some drivers (LLVMpipe).
        # Recommended if it works.
        # glx-no-rebind-pixmap = true;

        # GLX backend: GLX buffer swap method we assume.
        # Could be undefined (0), copy (1), exchange (2), 3-6, or buffer-age (-1).
        # undefined is the slowest and the safest, and the default value.
        # copy is fastest, but may fail on some drivers,
        # 2-6 are gradually slower but safer (6 is still faster than 0).
        # Usually, double buffer means 2, triple buffer means 3.
        # buffer-age means auto-detect using GLX_EXT_buffer_age, supported by some drivers.
        # Useless with --glx-use-copysubbuffermesa.
        # Partially breaks --resize-damage.
        # Defaults to undefined.
        # glx-swap-method = "undefined";

        #################################
        #
        # Window type settings
        #
        #################################

        wintypes = {
          tooltip = {
            # fade: Fade the particular type of windows.
            fade = false;
            # shadow: Give those windows shadow
            shadow = false;
            # opacity: Default opacity for the type of windows.
            opacity = 1;
            # focus: Whether to always consider windows of this type focused.
            focus = true;
          };
        };

        ######################
        #
        # XSync
        # See: https://github.com/yshui/picom/commit/b18d46bcbdc35a3b5620d817dd46fbc76485c20d
        #
        ######################

        # Use X Sync fence to sync clients' draw calls, to make sure all draw
        # calls are finished before picom starts drawing. Needed on
        # nvidia-drivers with GLX backend for some users.
        xrender-sync-fence = true;
      };
    };
  };
}
