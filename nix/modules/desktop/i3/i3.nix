{ config
, lib
, pkgs
, modifier ? "Mod4"
, alt ? "Mod1"
, terminal ? "kitty"
, terminalFloating ? "kitty --title kitty-floating"
, fileManager ? "thunar"
, sessionLocker ? "dm-tool lock"
, sessionRefresher ? "switch"
, browser ? "google-chrome-stable"
, editor ? "emacs"
, messenger ? "slack"
, audioIncrease ? "pactl set-sink-volume @DEFAULT_SINK@ +5%"
, audioDecrease ? "pactl set-sink-volume @DEFAULT_SINK@ -5%"
, audioToggle ? "pactl set-sink-mute @DEFAULT_SINK@ toggle"
, audioPlay ? "playerctl play"
, audioPause ? "playerctl pause"
, audioPrev ? "playerctl previous"
, audioNext ? "playerctl next"
, micMute ? "pactl set-source-mute @DEFAULT_SOURCE@ toggle"
, exit ? "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'"
, i3-input ? "i3-input -f 'pango:Victor Mono 12'"
, ...
}:

with builtins;
with lib;

let
  inherit (config.xdg) configHome;

  # modes = {
  #   apps = {
  #     "Enter" = ''[class="kitty"] focus'';
  #     "Space" = ''[class="Chromium"] focus'';
  #     "e" = ''[class="Emacs"] focus'';
  #     "s" = ''[class="Slack"] focus'';
  #     "l" = ''[class="Linear.*"] focus'';
  #   };
  # };

in
{
  enable = true;

  config = lib.mkOptionDefault rec {

    inherit modifier terminal;

    keybindings =
      let
        groups = {
          session = {
            "${modifier}+Shift+q" = "kill";
            "${modifier}+${alt}+q" =
              "exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";
            "${modifier}+Ctrl+q" = "exec ${pkgs.xorg.xkill}/bin/xkill";
            "${modifier}+Ctrl+c" = "restart";
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+e" = exit;
            "${modifier}+Shift+semicolon" = "exec ${i3-input} -P 'i3-msg: '";
            "Ctrl+${alt}+Delete" = "exec ${sessionLocker}";
            "${modifier}+F2;" = ''exec ${i3-input} -F 'rename workspace to "%s "' -P 'New name: ''''';
            "${modifier}+F5" = "exec ${sessionRefresher}";
          };

          focusWindow = {
            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";
          };

          resize = {
            "${modifier}+r" = "mode resize";
            "${modifier}+equal" = "exec i3_balance_workspace";
          };

          apps = {
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+${alt}+Return" = "exec ${terminalFloating}";
            "${modifier}+Shift+Return" = "exec ${browser}";
            "${modifier}+e" = "exec ${editor}";
            "${modifier}+n" = "exec ${fileManager}";
            "${modifier}+s" = "exec ${messenger}";
          };

          menus = {
            "${modifier}+space" = "exec --no-startup-id rofi-launcher";
            "${modifier}+colon" = "exec --no-startup-id rofi-run";
            "${modifier}+w" = "exec --no-startup-id rofi-window";
            "${modifier}+p" = "exec --no-startup-id rofi-powermenu";
            "${modifier}+a" = "exec --no-startup-id rofi-volume";
          };

          focusWorkspaceAbsolute = {
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
          };

          focusWorkspaceRelative = {
            "${modifier}+Tab" = "workspace back_and_forth";
            "${modifier}+Left" = "workspace prev";
            "${modifier}+Right" = "workspace next";
            "${modifier}+bracketleft" = "workspace prev";
            "${modifier}+bracketright" = "workspace next";
          };

          jumpWindow = {
            "${modifier}+comma" = "[con_mark=_prevFocus0] focus";
            "${modifier}+ctrl+comma" = "[con_mark=_prevFocus2] focus";
          };

          focusOutput = {
            "${modifier}+Ctrl+Left" = "workspace prev_on_output";
            "${modifier}+Ctrl+Right" = "workspace next_on_output";
            "${modifier}+Ctrl+bracketleft" = "workspace prev_on_output";
            "${modifier}+Ctrl+bracketright" = "workspace next_on_output";
            "${modifier}+Ctrl+Tab" = "workspace next_on_output";
            "${modifier}+Ctrl+Shift+Tab" = "workspace prev_on_output";
          };

          moveWindowPosition = {
            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";
          };

          moveWindowToWorkspace = {
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
          };

          carryWindowToWorkspace = {
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
          };

          modifyWorkspace = {
            "${modifier}+Ctrl+Shift+h" = "move workspace to output left";
            "${modifier}+Ctrl+Shift+j" = "move workspace to output down";
            "${modifier}+Ctrl+Shift+k" = "move workspace to output up";
            "${modifier}+Ctrl+Shift+l" = "move workspace to output right";
            "${modifier}+Ctrl+Shift+Left" = "move workspace to output left";
            "${modifier}+Ctrl+Shift+Right" = "move workspace to output right";
            "${modifier}+Ctrl+Shift+Up" = "move workspace to output up";
            "${modifier}+Ctrl+Shift+Down" = "move workspace to output down";
          };

          split = {
            "${modifier}+v" = "split vertical";
            "${modifier}+g" = "split horizontal";
            "${modifier}+BackSpace" = "split toggle";
          };

          ## Modify // Window space
          fullscreen = {
            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+Shift+f" = "floating toggle";
          };

          sticky = {
            "${modifier}+s" = "floating toggle; sticky toggle";
          };

          ## Modify // Window layout
          layout = {
            "${modifier}+t" = "focus mode_toggle";
            "${modifier}+Shift+t" = "layout toggle tabbed splith splitv";
          };

          scratchpad = {
            "${modifier}+Shift+grave" = "scratchpad hide; move scratchpad";
            "${modifier}+grave" = "[class=.*] scratchpad show ";
          };

          media = {
            "XF86AudioRaiseVolume " = "exec --no-startup-id ${audioIncrease}";
            "XF86AudioLowerVolume" = "exec --no-startup-id ${audioDecrease}";
            "XF86AudioMute" = "exec --no-startup-id ${audioToggle}";
            "XF86AudioPlay" = "exec --no-startup-id ${audioPlay}";
            "XF86AudioPause" = "exec --no-startup-id ${audioPause}";
            "XF86AudioNext" = "exec --no-startup-id ${audioNext}";
            "XF86AudioPrev" = "exec --no-startup-id ${audioPrev}";
            "Scroll_Lock" = "exec --no-startup-id ${micMute}";
          };

          resize = {
            "${modifier}+${alt}+h" = "resize shrink width 18 px or 2 ppt";
            "${modifier}+${alt}+j" = "resize grow height 18 px or 2 ppt";
            "${modifier}+${alt}+k" = "resize shrink height 18 px or 2 ppt";
            "${modifier}+${alt}+l" = "resize grow width 18 px or 2 ppt";
          };

          capture = {
            "Print" = "exec ${config.services.flameshot.package}/bin/flameshot gui";
          };

        };
      in
      foldl' mergeAttrs { } (attrValues groups);

    modes = {
      resize = {
        "h" = "resize shrink width 8 px or 1 ppt";
        "j" = "resize grow height 8 px or 1 ppt";
        "k" = "resize shrink height 8 px or 1 ppt";
        "l" = "resize grow width 8 px or 1 ppt";

        "Shift+h" = "resize shrink width 24 px or 3 ppt";
        "Shift+j" = "resize grow height 24 px or 3 ppt";
        "Shift+k" = "resize shrink height 24 px or 3 ppt";
        "Shift+l" = "resize grow width 24 px or 3 ppt";

        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";

        # Move position by mouse
        "button1" = "move position mouse"; # move container to current position of mouse cursor
        "button2" = "exec ${./scripts/draw-resize.sh}";
        "button4" = "move up 1 ppt"; # scroll wheel up
        "button5" = "move down 1 ppt"; # scroll wheel down
        "button6" = "move right 1 ppt"; # scroll wheel right
        "button7" = "move left 1 ppt"; # scroll wheel right

        "${modifier}+r" = "mode default";
        "Escape" = "mode default";
        "Ctrl+c" = "mode default";
        "Ctrl+g" = "mode default";
      };
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

    bars = [ ]; # disable for polybar

    # fonts.names = [ config.gtk.font.name "FontAwesome" ];
    # fonts.size =
    #   mkIf (config.gtk.font.size != null) (builtins.toFloat config.gtk.font.size);

    focus = {
      followMouse = false;
      # wrapping = "no";
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
    };

    floating = import ./floating.nix;

    assigns = {
      "1" = [ ];
      "2" = [ ];
      "3" = [ ];
      "4" = [ ];
      "5" = [ ];
      "6" = [ ];
      "7" = [ ];
      "8" = [ ];
      "9: Chat" = [{ class = "Slack"; }];
      "0" = [ ];
    };

    startup = [
      (mkIf (!isNull config.modules.theme.wallpaper) {
        command = "feh --bg-scale ${config.modules.theme.wallpaper}";
        always = true;
        notification = false;
      })
      {
        command = "systemctl --user restart polybar";
        always = true;
        notification = false;
      }
      {
        command = "${./i3-focus-marker.sh}";
        always = true;
        notification = false;
      }
      # {
      #   command = editor;
      #   workspace = "1";
      # }
      # {
      #   command = terminal;
      #   workspace = "2";
      # }
      # {
      #   command = browser;
      #   workspace = "3";
      # }
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
  };
  extraConfig = ''
    # Only enable outer gaps when there is exactly one window or split container on the workspace.
    smart_gaps inverse_outer

    # Notification menu
    set $mode_notify dunst: [RET] action [+RET] context  [k|n] close [K] close-all [p] history-pop [t] (un)pause [q] exit
    mode --pango_markup "$mode_notify" {
        bindsym Return       exec "dunstctl action 0"       ; mode "default"
        bindsym Shift+Return exec dunstctl context          ; mode "default"
        bindsym k            exec dunstctl close            ; mode "default"
        bindsym Shift+k      exec dunstctl close-all        ; mode "default"
        bindsym n            exec dunstctl close
        bindsym p            exec dunstctl history-pop
        bindsym t            exec dunstctl set-paused toggle; mode "default"

        bindsym q mode "default"
        bindsym Escape mode "default"
        bindsym Ctrl+c mode "default"
        bindsym Ctrl+g mode "default"
    }
    bindsym ${modifier}+period mode "$mode_notify"
  '';
}
