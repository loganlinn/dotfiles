{
  config,
  lib,
  pkgs,
  modifier ? "Mod4",
  alt ? "Mod1",
  terminal ? "kitty",
  menu ? "rofi -show drun",
  fileManager ? "thunar",
  sessionLocker ? "dm-tool lock",
  sessionRefresher ? "switch",
  browser ? "google-chrome-stable",
  editor ? "emacs",
  messenger ? "slack",
  backgroundImage ? "~/.background-image",
  audioIncrease ? "pactl set-sink-volume @DEFAULT_SINK@ +5%",
  audioDecrease ? "pactl set-sink-volume @DEFAULT_SINK@ -5%",
  audioToggle ? "pactl set-sink-mute @DEFAULT_SINK@ toggle",
  audioPlay ? "playerctl play",
  audioPause ? "playerctl pause",
  audioPrev ? "playerctl previous",
  audioNext ? "playerctl next",
  micMute ? "pactl set-source-mute @DEFAULT_SOURCE@ toggle",
  ...
}: rec {
  inherit modifier terminal menu;

  keybindings = {
    ## Session
    "${modifier}+Shift+q" = "kill";
    "${modifier}+${alt}+q" = "exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";
    "${modifier}+Shift+c" = "reload";
    "${modifier}+Ctrl+c" = "restart";
    "${modifier}+Escape" = "exec ${sessionLocker}";
    "${modifier}+F5" = "exec ${sessionRefresher}";
    "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

    "XF86AudioRaiseVolume" = "exec ${audioIncrease}";
    "XF86AudioLowerVolume" = "exec ${audioDecrease}";
    "XF86AudioMute" = "exec ${audioToggle}";
    "XF86AudioPlay" = "exec ${audioPlay}";
    "XF86AudioPause" = "exec ${audioPause}";
    "XF86AudioNext" = "exec ${audioNext}";
    "XF86AudioPrev" = "exec ${audioPrev}";
    "Scroll_Lock"   = "exec ${micMute}";

    ## Modes
    "${modifier}+r" = "mode resize";

    ## Launchers // Applications
    "${modifier}+Return" = "exec ${terminal}";
    "${modifier}+Shift+Return" = "exec ${browser}";
    "${modifier}+e" = "exec ${editor}";
    "${modifier}+n" = "exec ${fileManager}";
    "${modifier}+s" = "exec ${messenger}";

    ## Launchers // Menus
    "${modifier}+space" = "exec ${menu}";
    "${modifier}+Shift+space" = "exec rofi -show run";
    "${modifier}+Ctrl+space" = "exec rofi -show window";

    ## Navigate // Focus relative window
    "${modifier}+h" = "focus left";
    "${modifier}+j" = "focus down";
    "${modifier}+k" = "focus up";
    "${modifier}+l" = "focus right";

    ## Navigate // Focus workspace
    "${modifier}+1" = "workspace number 1";
    "${modifier}+2" = "workspace number 2";
    "${modifier}+3" = "workspace number 3";
    "${modifier}+4" = "workspace number 4";
    "${modifier}+5" = "workspace number 5";
    "${modifier}+6" = "workspace number 6";
    "${modifier}+7" = "workspace number 7";
    "${modifier}+8" = "workspace number 8";
    "${modifier}+9" = "workspace number 9";
    "${modifier}+0" = "workspace number 10";

    ## Navigate // Focus workspace
    "${modifier}+Tab" = "workspace back_and_forth";
    "${modifier}+Left" = "workspace prev";
    "${modifier}+Right" = "workspace next";
    "${modifier}+bracketleft" = "workspace prev";
    "${modifier}+bracketright" = "workspace next";

    ## Navigate // Focus output
    "${modifier}+Ctrl+Left" = "workspace prev_on_output";
    "${modifier}+Ctrl+Right" = "workspace next_on_output";
    "${modifier}+Ctrl+bracketleft" = "workspace prev_on_output";
    "${modifier}+Ctrl+bracketright" = "workspace next_on_output";
    "${modifier}+Ctrl+Tab" = "workspace next_on_output";
    "${modifier}+Ctrl+Shift+Tab" = "workspace prev_on_output";

    ## Navigate // Focus application
    "${modifier}+Control+e" = ''[class="${editor}"] focus'';
    "${modifier}+Control+s" = ''[class="${messenger}"] focus'';
    "${modifier}+Control+d" = ''[title="Linear"] focus'';
    "${modifier}+Control+f" = ''[class="kitty"] focus'';
    "${modifier}+Control+g" = ''[class="Chromium"] focus'';

    ## Modify // Window position
    "${modifier}+Shift+h" = "move left";
    "${modifier}+Shift+j" = "move down";
    "${modifier}+Shift+k" = "move up";
    "${modifier}+Shift+l" = "move right";

    ## Modify // Move window to workspace
    "${modifier}+Shift+1" = "move container to workspace number 1";
    "${modifier}+Shift+2" = "move container to workspace number 2";
    "${modifier}+Shift+3" = "move container to workspace number 3";
    "${modifier}+Shift+4" = "move container to workspace number 4";
    "${modifier}+Shift+5" = "move container to workspace number 5";
    "${modifier}+Shift+6" = "move container to workspace number 6";
    "${modifier}+Shift+7" = "move container to workspace number 7";
    "${modifier}+Shift+8" = "move container to workspace number 8";
    "${modifier}+Shift+9" = "move container to workspace number 9";
    "${modifier}+Shift+0" = "move container to workspace number 10";
    "${modifier}+Shift+Ctrl+1" = "move container to workspace number 11";
    "${modifier}+Shift+Ctrl+2" = "move container to workspace number 12";
    "${modifier}+Shift+Ctrl+3" = "move container to workspace number 13";
    "${modifier}+Shift+Ctrl+4" = "move container to workspace number 14";
    "${modifier}+Shift+Ctrl+5" = "move container to workspace number 15";
    "${modifier}+Shift+Ctrl+6" = "move container to workspace number 16";
    "${modifier}+Shift+Ctrl+7" = "move container to workspace number 17";
    "${modifier}+Shift+Ctrl+8" = "move container to workspace number 18";
    "${modifier}+Shift+Ctrl+9" = "move container to workspace number 19";
    "${modifier}+Shift+Ctrl+0" = "move container to workspace number 20";
    # TODO package https://github.com/regolith-linux/i3-next-workspace/blob/main/i3-next-workspace

    ## Modify // Carry window to workspace
    "${modifier}+${alt}+1" = "move container to workspace number 1; workspace number 1";
    "${modifier}+${alt}+2" = "move container to workspace number 2; workspace number 2";
    "${modifier}+${alt}+3" = "move container to workspace number 3; workspace number 3";
    "${modifier}+${alt}+4" = "move container to workspace number 4; workspace number 4";
    "${modifier}+${alt}+5" = "move container to workspace number 5; workspace number 5";
    "${modifier}+${alt}+6" = "move container to workspace number 6; workspace number 6";
    "${modifier}+${alt}+7" = "move container to workspace number 7; workspace number 7";
    "${modifier}+${alt}+8" = "move container to workspace number 8; workspace number 8";
    "${modifier}+${alt}+9" = "move container to workspace number 9; workspace number 9";
    "${modifier}+${alt}+0" = "move container to workspace number 10; workspace number 10;";
    "${modifier}+${alt}+Ctrl+1" = "move container to workspace number 11; workspace number 11";
    "${modifier}+${alt}+Ctrl+2" = "move container to workspace number 12; workspace number 12";
    "${modifier}+${alt}+Ctrl+3" = "move container to workspace number 13; workspace number 13";
    "${modifier}+${alt}+Ctrl+4" = "move container to workspace number 14; workspace number 14";
    "${modifier}+${alt}+Ctrl+5" = "move container to workspace number 15; workspace number 15";
    "${modifier}+${alt}+Ctrl+6" = "move container to workspace number 16; workspace number 16";
    "${modifier}+${alt}+Ctrl+7" = "move container to workspace number 17; workspace number 17";
    "${modifier}+${alt}+Ctrl+8" = "move container to workspace number 18; workspace number 18";
    "${modifier}+${alt}+Ctrl+9" = "move container to workspace number 19; workspace number 19";

    ## Modify // Containing Workspace
    "${modifier}+Ctrl+Shift+h" = "move workspace to output left";
    "${modifier}+Ctrl+Shift+j" = "move workspace to output down";
    "${modifier}+Ctrl+Shift+k" = "move workspace to output up";
    "${modifier}+Ctrl+Shift+l" = "move workspace to output right";
    "${modifier}+Ctrl+Shift+Left" = "move workspace to output left";
    "${modifier}+Ctrl+Shift+Right" = "move workspace to output right";
    "${modifier}+Ctrl+Shift+Up" = "move workspace to output up";
    "${modifier}+Ctrl+Shift+Down" = "move workspace to output down";

    ## Modify // Window orientation
    "${modifier}+v" = "split vertical";
    "${modifier}+g" = "split horizontal";
    "${modifier}+BackSpace" = "split toggle";

    ## Modify // Window space
    "${modifier}+f" = "fullscreen toggle";
    "${modifier}+Shift+f" = "floating toggle";

    ## Modify // Window layout
    "${modifier}+t" = "focus mode_toggle";
    "${modifier}+Shift+t" = "layout toggle tabbed splith splitv";

    ## Scratchpad // Navigate and modify
    "${modifier}+Shift+grave" = "move scratchpad";
    "${modifier}+grave" = "scratchpad show";
  };

  modes = let
    inherit (builtins) isString;
    resizeSmall = "10 px or 2 ppt";
    resizeLarge = "30 px or 6 ppt";
    resizeKeybinds = {
      wider,
      narrower,
      taller,
      shorter,
    }: {
      "${narrower}" = "resize shrink width ${resizeSmall}";
      "${taller}" = "resize grow height ${resizeSmall}";
      "${shorter}" = "resize shrink height ${resizeSmall}";
      "${wider}" = "resize grow width ${resizeSmall}";
      "Shift+${narrower}" = "resize shrink width ${resizeLarge}";
      "Shift+${taller}" = "resize grow height ${resizeLarge}";
      "Shift+${shorter}" = "resize shrink height ${resizeLarge}";
      "Shift+${wider}" = "resize grow width ${resizeLarge}";
    };
    quitModeKeybinds = {
      "Escape" = "mode default";
      "Ctrl+c" = "mode default";
      "Ctrl+g" = "mode default";
    };
  in {
    resize =
      resizeKeybinds {
        wider = "h";
        taller = "j";
        shorter = "k";
        narrower = "l";
      }
      // resizeKeybinds {
        wider = "Left";
        taller = "Up";
        shorter = "Down";
        narrower = "Right";
      }
      // quitModeKeybinds;

    # TODO
    # gaps = {
    #     o      "mode mode_gaps_outer"
    #     i      "mode mode_gaps_inner"
    #     h      "mode mode_gaps_horiz"
    #     v      "mode mode_gaps_verti"
    #     t      "mode mode_gaps_top"
    #     r      "mode mode_gaps_right"
    #     b      "mode mode_gaps_bottom"
    #     l      "mode mode_gaps_left"
    #     Return "mode gaps"
    # };
  };

  bars = [];

  fonts.names = [config.gtk.font.name "FontAwesome"];
  fonts.size = lib.mkIf (config.gtk.font.size != null) (builtins.toFloat config.gtk.font.size);

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
    smartBorders = "no_gaps";
    smartGaps = true;
  };

  floating = {
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
      {title = "Event Tester";} # i.e. xev
    ];
  };

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
      command = "feh --bg-scale ${backgroundImage}";
      always = true;
      notification = false;
    }
    {
      command = "systemctl --user restart polybar";
      always = true;
      notification = false;
    }
  ];

  defaultWorkspace = "workspace number 1";
  workspaceLayout = "default";

  # colors = {
  #   background = "#${colorscheme.Black}";
  #   focused = {
  #     background = "#${colorscheme.Blue}";
  #     border = "#${colorscheme.Blue}";
  #     childBorder = "#${colorscheme.Blue}";
  #     indicator = "#${colorscheme.Blue}";
  #     text = "#${colorscheme.Black}";
  #   };
  #   focusedInactive = {
  #     background = "#${colorscheme.BrightBlack}";
  #     border = "#${colorscheme.BrightBlack}";
  #     childBorder = "#${colorscheme.BrightBlack}";
  #     indicator = "#${colorscheme.Black}";
  #     text = "#${colorscheme.Black}";
  #   };
  #   unfocused = {
  #     background = "#${colorscheme.Black}";
  #     border = "#${colorscheme.BrightBlack}";
  #     childBorder = "#${colorscheme.BrightBlack}";
  #     indicator = "#${colorscheme.Black}";
  #     text = "#${colorscheme.Blue}";
  #   };
  #   urgent = {
  #     background = "#${colorscheme.Red}";
  #     border = "#${colorscheme.Red}";
  #     childBorder = "#${colorscheme.Red}";
  #     indicator = "#${colorscheme.Red}";
  #     text = "#${colorscheme.Black}";
  #   };
  # };
}
