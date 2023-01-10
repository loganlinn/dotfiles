{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  bins = rec {
    kitty = getExe config.programs.kitty.package;
    rofi = getExe config.programs.rofi.package;
    google_chrome = getExe config.programs.google-chrome.package;
    emacs = getExe config.programs.emacs.package;
    neovim = getExe config.programs.neovim.package;

    terminal = kitty;
    browser = google_chrome;
  };
in {
  home.file.".background-image".source = ./background.jpg;

  xsession.enable = true;
  xsession.windowManager.i3 = let
    keysyms = {
      alt = "Mod1";
      super = "Mod4";
      # directions = {
      #   left = [ "Left" "h" ];
      #   down = [ "Down" "j" ];
      #   up = [ "Up" "k" ];
      #   right = [ "Right" "l" ];
      # };
    };

    quitModeKeybinds = {
      "Escape" = "mode default";
      "Ctrl+c" = "mode default";
      "Ctrl+g" = "mode default";
    };

    resizeKeybinds = {
      wider,
      narrower,
      taller,
      shorter,
    }: {
      "${narrower}" = "resize shrink width 10px or 2 ppt";
      "${taller}" = "resize grow height 10px or 2 ppt";
      "${shorter}" = "resize shrink height 10px or 2 ppt";
      "${wider}" = "resize grow width 10px or 2 ppt";

      "Shift+${narrower}" = "resize shrink width 50px or 10 ppt";
      "Shift+${taller}" = "resize grow height 50px or 10 ppt";
      "Shift+${shorter}" = "resize shrink height 50px or 10 ppt";
      "Shift+${wider}" = "resize grow width 50px or 10 ppt";
    };
  in {
    enable = true;
    # package = pkgs.i3-gaps;
    config = {
      terminal = bins.terminal;
      menu = "${bins.rofi} -show drun";
      modifier = keysyms.super;
      keybindings = with keysyms;
        mkOptionDefault {
          "${super}+Return" = "exec ${bins.kitty}";
          "${super}+Shift+Return" = "exec ${bins.browser}";
          "${super}+e" = "exec ${bins.emacs}";
          "${super}+Shift+n" = "exec thunar";
          "${super}+space" = "exec ${bins.rofi} -show drun";
          "${super}+Shift+space" = "exec ${bins.rofi} -show run";
          "${super}+Ctrl+space" = "exec ${bins.rofi} -show window";
          "${super}+Shift+q" = "kill";
          "${super}+${alt}+q" = "exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";

          "${super}+h" = "focus left";
          "${super}+j" = "focus down";
          "${super}+k" = "focus up";
          "${super}+l" = "focus right";

          "${super}+Shift+h" = "move left";
          "${super}+Shift+j" = "move down";
          "${super}+Shift+k" = "move up";
          "${super}+Shift+l" = "move right";

          "${super}+Ctrl+Shift+h" = "move workspace to output left";
          "${super}+Ctrl+Shift+j" = "move workspace to output down";
          "${super}+Ctrl+Shift+k" = "move workspace to output up";
          "${super}+Ctrl+Shift+l" = "move workspace to output right";

          "${super}+Left" = "workspace prev";
          "${super}+Right" = "workspace next";
          "${super}+bracketleft" = "workspace prev";
          "${super}+bracketright" = "workspace next";

          "${super}+Ctrl+Left" = "workspace prev_on_output";
          "${super}+Ctrl+Right" = "workspace next_on_output";
          "${super}+Ctrl+bracketleft" = "workspace prev_on_output";
          "${super}+Ctrl+bracketright" = "workspace next_on_output";

          "${super}+Tab" = "workspace back_and_forth";

          # Carry window to workspace 1-10
          "${super}+${alt}+1" = "move container to workspace number 1; workspace number 1";
          "${super}+${alt}+2" = "move container to workspace number 2; workspace number 2";
          "${super}+${alt}+3" = "move container to workspace number 3; workspace number 3";
          "${super}+${alt}+4" = "move container to workspace number 4; workspace number 4";
          "${super}+${alt}+5" = "move container to workspace number 5; workspace number 5";
          "${super}+${alt}+6" = "move container to workspace number 6; workspace number 6";
          "${super}+${alt}+7" = "move container to workspace number 7; workspace number 7";
          "${super}+${alt}+8" = "move container to workspace number 8; workspace number 8";
          "${super}+${alt}+9" = "move container to workspace number 9; workspace number 9";
          "${super}+${alt}+0" = "move container to workspace number 10; workspace number 10;";

          "${super}+Shift+grave" = "move scratchpad";
          "${super}+grave" = "scratchpad show";

          # Carry window to next free workspace
          # "${mod}+grave" = "i3-next-workspace"; # TODO create package for https://github.com/regolith-linux/i3-next-workspace/blob/main/i3-next-workspace

          "${super}+Shift+F5" = "exec switch";
          "${super}+Shift+c" = "reload";

          "${super}+r" = "mode resize";

          "${super}+v" = "split vertical";
          "${super}+g" = "split horizontal";
          "${super}+BackSpace" = "split toggle";

          "${super}+f" = "fullscreen toggle";
          "${super}+Shift+f" = "floating toggle";
          "${super}+t" = "focus mode_toggle";
          "${super}+Shift+t" = "layout toggle tabbed splith splitv";

          "${super}+Control+e" = ''[class="Emacs"] focus'';
          "${super}+Control+s" = ''[class="Slack"] focus'';
          "${super}+Control+d" = ''[title="Linear"] focus'';
          "${super}+Control+f" = ''[class="kitty"] focus'';
          "${super}+Control+g" = ''[class="Chromium"] focus'';

          "${super}+Escape" = "exec dm-tool switch-to-greeter";
        };
      keycodebindings = {
        # "214" = "exec /bin/script.sh";
      };
      modes = {
        resize =
          resizeKeybinds {
            narrower = "h";
            taller = "j";
            shorter = "k";
            wider = "l";
          }
          // quitModeKeybinds;
      };
      bars = [];
      fonts = {
        names = [
          "pango:DejaVu Sans Mono"
          #"Noto Sans"
        ];
        size = 10.0;
      };
      focus = {
        followMouse = false;
        forceWrapping = false;
        mouseWarping = true;
        newWindow = "focus";
      };
      gaps = {
        horizontal = 5;
        vertical = 5;
        inner = 5;
        outer = 5;
        left = 5;
        right = 5;
        top = 5;
        bottom = 5;
        smartBorders = "no_gaps";
        smartGaps = true;
      };
      floating = {
        modifier = keysyms.super; # for dragging floating windows
        criteria = [
          {class = "blueman-manager";}
          {class = "nm-connection-editor";}
          {class = "obs";}
          {class = "syncthingtray";}
          {class = "thunar";}
          {class = "System76 Keyboard Configurator";}
          {class = "pavucontrol";}
          {title = "Artha";}
          {title = "Calculator";}
          {title = "Steam.*";}
          {title = "doom-capture";}
          {class = "zoom";}
          {window_role = "pop-up";}
          {window_role = "prefwindow";}
        ];
      };
      defaultWorkspace = "workspace number 1";
      workspaceLayout = "default";
      workspaceAutoBackAndForth = false;
      assigns = {
        "1" = [];
        "2" = [];
        "3" = [];
        "4: Linear" = [{title = "Linear";}];
        "5" = [];
        "6" = [];
        "7" = [];
        "8: Email" = [{class = "Geary";}];
        "9: Chat" = [{class = "Slack";}];
        "0" = [];
      };
      startup = [
        {
          command = "feh --bg-scale ${./background.jpg}";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar";
          always = true;
          notification = false;
        }
      ];
    };
  };

  programs.feh.enable = true;

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
    shadowExclude = [
      # Put shadows on notifications, the scratch popup and rofi only
      "! name~='(rofi|scratch|Dunst)$'"
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

  services.clipmenu = {
    enable = true;
    launcher = bins.rofi;
  };
}
