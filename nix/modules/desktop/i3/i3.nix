{ self
, config
, lib
, pkgs
, ...
}:

with builtins;
with lib;

let

  cfg = config.modules.desktop.i3;
  themeCfg = config.modules.theme;

  inherit (config.xdg) configHome;

  super = "Mod4";
  alt = "Mod1";

  pactl = args: "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl ${args}";
  playerctl = args: "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl ${args}";
  ponymix = args: "exec --no-startup-id ${pkgs.ponymix}/bin/ponymix ${args}";
in
{
  options.modules.desktop.i3 = {
    # sessionLocker ?
    # ?
    # i3-input ? "i3-input -f 'pango:Victor Mono 12'"
    locker = mkOption {
      type = with types; nullOr str;
      default = null;
    };

  };
  config = {
    xsession.windowManager.i3 = {
      config = lib.mkOptionDefault rec {

        modifier = super;

        keybindings =
          let
            groups = {
              session = {
                "${super}+Shift+q" = "kill";
                "${super}+${alt}+q" =
                  "exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";
                "${super}+Ctrl+q" = "exec ${pkgs.xorg.xkill}/bin/xkill";
                "${super}+Ctrl+c" = "restart";
                "${super}+Shift+c" = "reload";
                "${super}+Shift+p" = ''exec --no-startup-id i3-msg exit, mode "default"'';
                "${super}+Shift+semicolon" = "exec --no-startup-id i3-input -P 'i3-msg: '";
                "${super}+F2;" = ''exec --no-startup-id i3-input -F 'rename workspace to "%s "' -P 'New name: ''''';
              } // optionalAttrs (!isNull cfg.locker) {
                "${super}+Escape" = "exec --no-startup-id ${cfg.locker}";
              };

              focusWindow = {
                "${super}+h" = "focus left";
                "${super}+j" = "focus down";
                "${super}+k" = "focus up";
                "${super}+l" = "focus right";
              };

              resize = {
                "${super}+r" = "mode resize";
                "${super}+equal" = "exec i3_balance_workspace";
                "${super}+Shift+r" = "mode $mode_gaps";
              };

              browser = let chrome = "google-chrome-stable"; in
                {
                  "${super}+Shift+Return" = ''exec ${chrome} "--profile-directory=Profile 1"''; # work
                  "${super}+Shift+Ctrl+Return" = ''exec ${chrome} "--profile-directory=Profile 1" --app-id=bgdbmehlmdmddlgneophbcddadgknlpm''; # linear
                  "${super}+${alt}+Return" = ''exec ${chrome} "--profile-directory=Default"''; # personal
                };

              explorer = {
                "${super}+f" = ''exec --no-startup-id kitty --class Ranger ${pkgs.ranger}/bin/ranger'';
                "${super}+Shift+f" = ''exec thunar'';
              };

              editor = {
                "${super}+e" = ''exec emacs'';
                "${super}+Shift+e" = ''[class="emacs"] focus'';
                "${super}+${alt}+e" = ''exec emacsclient -a "" -c'';
              };

              terminal = {
                "${super}+Return" = "exec kitty";
                "${super}+Ctrl+Return" = "exec kitty --title kitty-one --single-instance";
              };

              menus = {
                "${super}+space" = "exec --no-startup-id rofi-launcher";
                "${super}+colon" = "exec --no-startup-id rofi-run";
                "${super}+w" = "exec --no-startup-id rofi-window";
                "${super}+p" = "exec --no-startup-id rofi-powermenu";
                "${super}+a" = "exec --no-startup-id rofi-volume";
              };

              notifications = {
                "${super}+n" = ''mode "$mode_notify"'';
                "${super}+Shift+n" = ''exec dunstctl set-paused toggle'';
              };

              focusWorkspaceAbsolute = {
                "${super}+1" = "workspace number 1";
                "${super}+2" = "workspace number 2";
                "${super}+3" = "workspace number 3";
                "${super}+4" = "workspace number 4";
                "${super}+5" = "workspace number 5";
                "${super}+6" = "workspace number 6";
                "${super}+7" = "workspace number 7";
                "${super}+8" = "workspace number 8";
                "${super}+9" = "workspace number 9";
                "${super}+0" = "workspace number 10";
              };

              focusWorkspaceRelative = {
                "${super}+Tab" = "workspace back_and_forth";
                "${super}+Left" = "workspace prev";
                "${super}+Right" = "workspace next";
                "${super}+bracketleft" = "workspace prev";
                "${super}+bracketright" = "workspace next";
              };

              jumpWindow = {
                "${super}+comma" = "[con_mark=_prevFocus0] focus";
                "${super}+ctrl+comma" = "[con_mark=_prevFocus2] focus";
              };

              focusOutput = {
                "${super}+Ctrl+Left" = "workspace prev_on_output";
                "${super}+Ctrl+Right" = "workspace next_on_output";
                "${super}+Ctrl+bracketleft" = "workspace prev_on_output";
                "${super}+Ctrl+bracketright" = "workspace next_on_output";
                "${super}+Ctrl+Tab" = "workspace next_on_output";
                "${super}+Ctrl+Shift+Tab" = "workspace prev_on_output";
              };

              moveWindowPosition = {
                "${super}+Shift+h" = "move left";
                "${super}+Shift+j" = "move down";
                "${super}+Shift+k" = "move up";
                "${super}+Shift+l" = "move right";
              };

              moveWindowToWorkspace = {
                "${super}+Shift+1" = "move container to workspace number 1";
                "${super}+Shift+2" = "move container to workspace number 2";
                "${super}+Shift+3" = "move container to workspace number 3";
                "${super}+Shift+4" = "move container to workspace number 4";
                "${super}+Shift+5" = "move container to workspace number 5";
                "${super}+Shift+6" = "move container to workspace number 6";
                "${super}+Shift+7" = "move container to workspace number 7";
                "${super}+Shift+8" = "move container to workspace number 8";
                "${super}+Shift+9" = "move container to workspace number 9";
                "${super}+Shift+0" = "move container to workspace number 10";
                "${super}+Shift+Ctrl+1" = "move container to workspace number 11";
                "${super}+Shift+Ctrl+2" = "move container to workspace number 12";
                "${super}+Shift+Ctrl+3" = "move container to workspace number 13";
                "${super}+Shift+Ctrl+4" = "move container to workspace number 14";
                "${super}+Shift+Ctrl+5" = "move container to workspace number 15";
                "${super}+Shift+Ctrl+6" = "move container to workspace number 16";
                "${super}+Shift+Ctrl+7" = "move container to workspace number 17";
                "${super}+Shift+Ctrl+8" = "move container to workspace number 18";
                "${super}+Shift+Ctrl+9" = "move container to workspace number 19";
                "${super}+Shift+Ctrl+0" = "move container to workspace number 20";
              };

              carryWindowToWorkspace = {
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
                "${super}+${alt}+Ctrl+1" = "move container to workspace number 11; workspace number 11";
                "${super}+${alt}+Ctrl+2" = "move container to workspace number 12; workspace number 12";
                "${super}+${alt}+Ctrl+3" = "move container to workspace number 13; workspace number 13";
                "${super}+${alt}+Ctrl+4" = "move container to workspace number 14; workspace number 14";
                "${super}+${alt}+Ctrl+5" = "move container to workspace number 15; workspace number 15";
                "${super}+${alt}+Ctrl+6" = "move container to workspace number 16; workspace number 16";
                "${super}+${alt}+Ctrl+7" = "move container to workspace number 17; workspace number 17";
                "${super}+${alt}+Ctrl+8" = "move container to workspace number 18; workspace number 18";
                "${super}+${alt}+Ctrl+9" = "move container to workspace number 19; workspace number 19";
              };

              modifyWorkspace = {
                "${super}+Ctrl+Shift+h" = "move workspace to output left";
                "${super}+Ctrl+Shift+j" = "move workspace to output down";
                "${super}+Ctrl+Shift+k" = "move workspace to output up";
                "${super}+Ctrl+Shift+l" = "move workspace to output right";
                "${super}+Ctrl+Shift+Left" = "move workspace to output left";
                "${super}+Ctrl+Shift+Right" = "move workspace to output right";
                "${super}+Ctrl+Shift+Up" = "move workspace to output up";
                "${super}+Ctrl+Shift+Down" = "move workspace to output down";
              };

              split = {
                "${super}+v" = "split vertical";
                "${super}+g" = "split horizontal";
                "${super}+BackSpace" = "split toggle";
              };

              ## Modify // Window space
              fullscreen = {
                "${super}+m" = "fullscreen toggle";
              };

              sticky = {
                "${super}+s" = "floating toggle; sticky toggle";
              };

              ## Modify // Window layout
              layout = {
                "${super}+t" = "floating toggle";
                "${super}+Shift+t" = "layout toggle tabbed splith splitv";
              };

              scratchpad = {
                "${super}+Shift+grave" = "move scratchpad";
                "${super}+grave" = "[class=.*] scratchpad show "; # toggles all scratchpad windows
              };

              media = {
                # "XF86AudioRaiseVolume " = pactl "set-sink-volume @DEFAULT_SINK@ +5%";
                # "XF86AudioLowerVolume" = pactl "set-sink-volume @DEFAULT_SINK@ -5%";
                # "XF86AudioMute" = pactl "set-sink-mute @DEFAULT_SINK@ toggle";
                # "Scroll_Lock" = pactl "set-source-mute @DEFAULT_SOURCE@ toggle";
                "XF86AudioRaiseVolume " = ponymix "increase 5";
                "XF86AudioLowerVolume" = ponymix "decrease 5";
                "XF86AudioMute" = ponymix "--sink toggle";
                "Scroll_Lock" = ponymix "--source toggle";
                "XF86AudioPlay" = playerctl "play";
                "XF86AudioPause" = playerctl "pause";
                "XF86AudioNext" = playerctl "next";
                "XF86AudioPrev" = playerctl "previous";
              };

              resize = {
                "${super}+${alt}+h" = "resize shrink width 18 px or 2 ppt";
                "${super}+${alt}+j" = "resize grow height 18 px or 2 ppt";
                "${super}+${alt}+k" = "resize shrink height 18 px or 2 ppt";
                "${super}+${alt}+l" = "resize grow width 18 px or 2 ppt";
              };

              capture = {
                "Print" = "exec ${config.services.flameshot.package}/bin/flameshot gui";
              };

            };
          in
          foldl' self.lib.unionOfDisjoint { } (attrValues groups);

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

            "${super}+h" = "focus left";
            "${super}+j" = "focus down";
            "${super}+k" = "focus up";
            "${super}+l" = "focus right";

            # Move position by mouse
            "button1" = "move position mouse"; # move container to current position of mouse cursor
            "button2" = "exec ${./scripts/draw-resize.sh}";
            "button4" = "move up 1 ppt"; # scroll wheel up
            "button5" = "move down 1 ppt"; # scroll wheel down
            "button6" = "move right 1 ppt"; # scroll wheel right
            "button7" = "move left 1 ppt"; # scroll wheel right

            "${super}+r" = "mode default";
            "Escape" = "mode default";
            "Ctrl+c" = "mode default";
            "Ctrl+g" = "mode default";
          };
        };

        bars = lib.mkIf config.services.polybar.enable [ ]; # disable for polybar

        fonts = {
          names = [
            "pango:${themeCfg.fonts.mono.name}"
            "pango:${themeCfg.fonts.sans.name}"
            "FontAwesome"
          ];
          size = 10.0;
        };

        focus = {
          followMouse = false;
          # wrapping = "no";
          forceWrapping = false;
          mouseWarping = true;
          newWindow = "focus";
        };

        gaps = let x = 6; in
          {
            horizontal = x;
            vertical = x;
            inner = x;
            outer = x;
            smartBorders = "no_gaps";
          };

        floating = {
          criteria = [
            { class = "notify"; }
            { class = "pop-up"; }
            { class = "kitty-one"; }
            { class = "kitty-floating"; }
            { class = "1Password.*"; }
            { class = "Qalculate.*"; }
            { class = "System76 Keyboard Configurator"; }
            { class = "blueman-manager"; }
            { class = "nm-connection-editor"; }
            { class = "obs"; }
            { class = "Pavucontrol"; }
            { class = "syncthingtray"; }
            { class = "Thunar"; }
            { class = "file-manager"; }
            { class = "Gcolor*"; }
            { class = "zoom"; }
            { class = "Ranger"; }
            { title = "Artha"; }
            { title = "Calculator"; }
            { title = "Event Tester"; } # i.e. xev
            { title = "Steam.*"; }
            { title = "doom-capture"; }
          ];
        };

        assigns = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
          "6" = [ ];
          "7" = [ ];
          "8" = [ ];
          "9" = [{ class = "Slack"; }];
          "0" = [ ];
        };

        startup = [
          (mkIf (!isNull config.modules.theme.wallpaper) {
            command = "${programs.feh.package}/bin/feh --bg-scale ${config.modules.theme.wallpaper}";
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
        ];

        defaultWorkspace = "workspace number 1";
        workspaceLayout = "default";
      };

      extraConfig = ''
        for_window [class="kitty-one"] move position center

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

        set $mode_gaps Gaps (o) outer, (i) inner
        set $mode_gaps_outer Outer Gaps (k/Up) grow locally, (K/Shift+Up) grow globally
        set $mode_gaps_inner Inner Gaps (k/Up) grow locally, (K/Shift+Up) grow globally

        mode "$mode_gaps" {
                bindsym o           mode "$mode_gaps_outer"
                bindsym i           mode "$mode_gaps_inner"
                bindsym Return      mode "$mode_gaps"
                bindsym Escape      mode "default"
        }

        mode "$mode_gaps_outer" {
                bindsym k           gaps outer current plus 5
                bindsym j           gaps outer current minus 5
                bindsym Up          gaps outer current plus 5
                bindsym Down        gaps outer current minus 5

                bindsym Shift+k     gaps outer all plus 5
                bindsym Shift+j     gaps outer all minus 5
                bindsym Shift+Up    gaps outer all plus 5
                bindsym Shift+Down  gaps outer all minus 5

                bindsym Return      mode "$mode_gaps"
                bindsym Escape      mode "default"
        }
        mode "$mode_gaps_inner" {
                bindsym k          gaps inner current plus 5
                bindsym j          gaps inner current minus 5
                # same bindings, but for the arrow keys
                bindsym Up         gaps inner current plus 5
                bindsym Down       gaps inner current minus 5

                bindsym Shift+k    gaps inner all plus 5
                bindsym Shift+j    gaps inner all minus 5
                # same keybindings, but for the arrow keys
                bindsym Shift+Up   gaps inner all plus 5
                bindsym Shift+Down gaps inner all minus 5

                bindsym Return     mode "$mode_gaps"
                bindsym Escape     mode "default"
        }

        bindsym ${super}+Shift+g mode "$mode_gaps"

        for_window [window_type="dialog,utility,toolbar,splash,menu,dropdown_menu,popup_menu,tooltip,notification,dock,prefwindow"] floating enable border pixel 1
        for_window [class="Lxappearance"] floating enable sticky enable border normal
        for_window [class="Nitrogen"] floating enable sticky enable border normal

      '';
    };
  };
}
