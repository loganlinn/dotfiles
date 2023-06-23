{ self
, config
, lib
, pkgs
, ...
}:
with builtins;
with lib; let
  inherit
    (lib)
    mkDefaultOption
    mkOption
    types
    ;

  cfg = config.modules.desktop.i3;
  configCfg = config.xsession.windowManager.i3.config;

  themeCfg = config.modules.theme;
  colors = config.colorScheme.colors;

  barHeight = 40; # TODO option shared w/ (poly)bar config

  super = "Mod4";
  alt = "Mod1";
  mouseWheelUp = "button4";
  mouseWheelDown = "button5";
  mouseWheelRight = "button6";
  mouseWheelLeft = "button7";

  playerctl = args: "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl ${args}";
  ponymix = args: "exec --no-startup-id ${pkgs.ponymix}/bin/ponymix ${args}";

  rofiCommandLineScript = lib.cli.toGNUCommandLineShell rec {
    mkOptionName = k: "-${k}";
    mkList = k: v: lib.optionals (v != [ ]) [ (mkOptionName k) (lib.concatStringsSep "," v) ];
  };

  # create  wrapper script for rofi commands to avoid collisions with i3 config parser
  rofi = show: options:
    let
      exe = "${config.programs.rofi.finalPackage}/bin/rofi";
      args = rofiCommandLineScript ({ inherit show; } // options);
    in
    pkgs.writeShellScript "rofi-${show}" "${exe} ${args}";

  execType = with types; oneOf [ path str ];

  mkStrOptDefault = default:
    lib.mkOption {
      type = types.str;
      inherit default;
    };
in
{
  options.modules.desktop.i3 = {
    keysyms.mod = mkStrOptDefault "Mod4";
    keysyms.alt = mkStrOptDefault "Mod1";
    keysyms.mouseButtonLeft = mkStrOptDefault "button1";
    keysyms.mouseButtonMiddle = mkStrOptDefault "button2";
    keysyms.mouseButtonRight = mkStrOptDefault "button3";
    keysyms.mouseWheelUp = mkStrOptDefault "button4";
    keysyms.mouseWheelDown = mkStrOptDefault "button5";
    keysyms.mouseWheelLeft = mkStrOptDefault "button6";
    keysyms.mouseWheelRight = mkStrOptDefault "button7";
    keysyms.menu = mkStrOptDefault "SunProps";

    # sessionLocker ?
    # ?
    # i3-input ? "i3-input -f 'pango:Victor Mono 12'"
    locker.exec = mkOption {
      type = with types; nullOr execType;
      default = null;
    };

    screenshot.exec = mkOption {
      type = execType;
      default = "${config.services.flameshot.package}/bin/flameshot gui";
    };

    editor.exec = mkOption {
      type = execType;
      default = "${pkgs.handlr}/bin/handlr launch text/plain";
    };

    terminal.exec = mkOption {
      type = execType;
      default =
        if config.programs.kitty.enable
        then "${config.programs.kitty.package}/bin/kitty"
        else if config.programs.foot.enable
        then "${config.programs.foot.package}/bin/foot"
        else if config.programs.alacritty.enable
        then "${config.programs.alacritty.package}/bin/alacritty"
        else "i3-sensible-terminal";
    };

    processManager.exec = mkOption {
      type = types.str;
      default =
        if config.programs.btop.enable
        then "${cfg.terminal.exec} --class ProcessManager ${config.programs.btop.package}/bin/btop"
        else if config.programs.bottom.enable
        then "${cfg.terminal.exec} --class ProcessManager ${config.programs.bottom.package}/bin/btm"
        else if config.programs.htop.enable
        then "${cfg.terminal.exec} --class ProcessManager ${config.programs.htop.package}/bin/htop"
        else "${cfg.terminal.exec} --class ProcessManager ${config.programs.proc.package}/bin/top";
    };
  };

  config = {
    programs.rofi.plugins = with pkgs; [ rofi-calc ]; # depended on below

    xsession.windowManager.i3 = {
      config = lib.mkOptionDefault {
        modifier = super;

        keybindings =
          let
            groups = {
              session =
                {
                  "$mod+Shift+q" = "kill";
                  "$mod+Shift+x" = "--release exec --no-startup-id ${pkgs.xdotool}/bin/xdotool selectwindow windowclose"; # alternatively, xkill
                  "$mod+$alt+q" = "--release exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";
                  "$mod+Ctrl+c" = "restart";
                  "$mod+Shift+c" = "reload";
                  # "$mod+Shift+p" = ''exec --no-startup-id i3-msg exit'';
                  "$mod+Shift+semicolon" = "exec --no-startup-id i3-input -P 'i3-msg: '";
                  "$mod+F2;" = ''exec --no-startup-id i3-input -F 'rename workspace to "%s "' -P 'New name: ''''';
                }
                // optionalAttrs (cfg.locker.exec != null) {
                  "$mod+Escape" = "exec --no-startup-id ${cfg.locker.exec}";
                };

              processManager = {
                "Ctrl+$alt+Delete" = ''exec ${cfg.processManager.exec}'';
              };

              clipboard = lib.optionalAttrs config.services.clipmenu.enable {
                "$mod+Shift+backslash" = ''exec --no-startup-id env CM_LAUNCHER=rofi clipmenu'';
              };

              focusWindow = {
                "$mod+h" = "focus left";
                "$mod+j" = "focus down";
                "$mod+k" = "focus up";
                "$mod+l" = "focus right";
                "$mod+backslash" = "focus parent";
              };

              webBrowser = {
                "$mod+Shift+Return" = "exec ${config.modules.desktop.browsers.default}";
                "$mod+$alt+Return" = "exec ${config.modules.desktop.browsers.alternate}";
              };

              explorer = {
                "$mod+Shift+n" = ''exec kitty --class Ranger ${pkgs.ranger}/bin/ranger'';
                "$mod+Shift+e" = ''exec thunar'';
              };

              editor = {
                "$mod+e" = ''exec ${cfg.editor.exec}'';
              };

              terminal = {
                "$mod+Return" = "exec kitty";
                "$mod+Ctrl+Return" = "exec kitty --title kitty-one --single-instance";
              };

              menus = {
                "$mod+space" = "exec --no-startup-id ${rofi "drun" {sidebar-mode = true;}}";
                "$mod+semicolon" = "exec --no-startup-id ${rofi "run" {}}";
                "$mod+Shift+space" = "--release exec --no-startup-id ${rofi "window" {modi = ["window" "windowcd"];}}";
                "$mod+Shift+equal" = "exec --no-startup-id ${rofi "calc" {}}";
                "$menu" = "exec ${pkgs.writeShellScript "rofi-power" ''
                  ${getExe config.programs.rofi.finalPackage} -show Power -modes "Power:${getExe pkgs.rofi-power-menu}"
                ''}";
              };

              focusWorkspaceAbsolute = {
                "$mod+1" = "workspace number 1";
                "$mod+2" = "workspace number 2";
                "$mod+3" = "workspace number 3";
                "$mod+4" = "workspace number 4";
                "$mod+5" = "workspace number 5";
                "$mod+6" = "workspace number 6";
                "$mod+7" = "workspace number 7";
                "$mod+8" = "workspace number 8";
                "$mod+9" = "workspace number 9";
                "$mod+0" = "workspace number 10";
              };

              focusWorkspaceRelative = {
                "$mod+Tab" = "workspace back_and_forth";
                "$mod+Shift+Tab" = "move container to workspace back_and_forth";
                "$mod+Left" = "workspace prev";
                "$mod+Right" = "workspace next";
                "$mod+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} focus";
                "$mod+bracketleft" = "workspace prev";
                "$mod+bracketright" = "workspace next";
              };

              jumpWindow = {
                "$mod+comma" = "[con_mark=_prevFocus0] focus";
                "$mod+ctrl+comma" = "[con_mark=_prevFocus2] focus";
              };

              moveWindowPosition = {
                "$mod+Shift+h" = "move left";
                "$mod+Shift+j" = "move down";
                "$mod+Shift+k" = "move up";
                "$mod+Shift+l" = "move right";
              };

              moveWindowToWorkspace = {
                "$mod+Shift+1" = "move container to workspace number 1";
                "$mod+Shift+2" = "move container to workspace number 2";
                "$mod+Shift+3" = "move container to workspace number 3";
                "$mod+Shift+4" = "move container to workspace number 4";
                "$mod+Shift+5" = "move container to workspace number 5";
                "$mod+Shift+6" = "move container to workspace number 6";
                "$mod+Shift+7" = "move container to workspace number 7";
                "$mod+Shift+8" = "move container to workspace number 8";
                "$mod+Shift+9" = "move container to workspace number 9";
                "$mod+Shift+0" = "move container to workspace number 10";
                "$mod+Shift+Ctrl+1" = "move container to workspace number 11";
                "$mod+Shift+Ctrl+2" = "move container to workspace number 12";
                "$mod+Shift+Ctrl+3" = "move container to workspace number 13";
                "$mod+Shift+Ctrl+4" = "move container to workspace number 14";
                "$mod+Shift+Ctrl+5" = "move container to workspace number 15";
                "$mod+Shift+Ctrl+6" = "move container to workspace number 16";
                "$mod+Shift+Ctrl+7" = "move container to workspace number 17";
                "$mod+Shift+Ctrl+8" = "move container to workspace number 18";
                "$mod+Shift+Ctrl+9" = "move container to workspace number 19";
                "$mod+Shift+Ctrl+0" = "move container to workspace number 20";
                "$mod+Shift+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} move";
              };

              carryWindowToWorkspace = {
                "$mod+$alt+1" = "move container to workspace number 1; workspace number 1";
                "$mod+$alt+2" = "move container to workspace number 2; workspace number 2";
                "$mod+$alt+3" = "move container to workspace number 3; workspace number 3";
                "$mod+$alt+4" = "move container to workspace number 4; workspace number 4";
                "$mod+$alt+5" = "move container to workspace number 5; workspace number 5";
                "$mod+$alt+6" = "move container to workspace number 6; workspace number 6";
                "$mod+$alt+7" = "move container to workspace number 7; workspace number 7";
                "$mod+$alt+8" = "move container to workspace number 8; workspace number 8";
                "$mod+$alt+9" = "move container to workspace number 9; workspace number 9";
                "$mod+$alt+0" = "move container to workspace number 10; workspace number 10;";
                "$mod+$alt+Ctrl+1" = "move container to workspace number 11; workspace number 11";
                "$mod+$alt+Ctrl+2" = "move container to workspace number 12; workspace number 12";
                "$mod+$alt+Ctrl+3" = "move container to workspace number 13; workspace number 13";
                "$mod+$alt+Ctrl+4" = "move container to workspace number 14; workspace number 14";
                "$mod+$alt+Ctrl+5" = "move container to workspace number 15; workspace number 15";
                "$mod+$alt+Ctrl+6" = "move container to workspace number 16; workspace number 16";
                "$mod+$alt+Ctrl+7" = "move container to workspace number 17; workspace number 17";
                "$mod+$alt+Ctrl+8" = "move container to workspace number 18; workspace number 18";
                "$mod+$alt+Ctrl+9" = "move container to workspace number 19; workspace number 19";
                "$mod+$alt+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} carry";
              };

              # Ctrl+Shift ~> per-output operations
              outputs = {
                "$mod+Ctrl+Shift+Tab" = "workspace next_on_output";
                "$mod+Ctrl+Shift+grave" = "workspace prev_on_output";

                "$mod+Ctrl+Shift+h" = "move workspace to output left";
                "$mod+Ctrl+Shift+j" = "move workspace to output down";
                "$mod+Ctrl+Shift+k" = "move workspace to output up";
                "$mod+Ctrl+Shift+l" = "move workspace to output right";

                "$mod+Ctrl+Shift+bracketleft" = "workspace prev_on_output";
                "$mod+Ctrl+Shift+bracketright" = "workspace next_on_output";

                "$mod+Ctrl+Shift+greater" = "move workspace to output primary";
                "$mod+Ctrl+Shift+less" = "move workspace to output nonprimary";
              };

              split = {
                "$mod+v" = "split vertical";
                "$mod+g" = "split horizontal";
                "$mod+BackSpace" = "split toggle";
              };

              ## Modify // Window space
              fullscreen = {
                "$mod+m" = "fullscreen toggle";
              };

              system = {
                "$mod+s" = "exec --no-startup-id ${getExe pkgs.rofi-systemd}";
              };

              ## Modify // Window layout
              layout = {
                "$mod+y" = "exec --no-startup-id ${pkgs.i3-layout-manager}/bin/layout_manager";
                "$mod+f" = "floating toggle";
                "$mod+Shift+f" = "floating toggle; sticky toggle";
                "$mod+t" = "layout toggle split";
                "$mod+Shift+t" = "layout toggle tabbed stacking split"; # TODO a mode would be more efficient
                "$mod+equal" = "exec ${import ./i3-balance-workspace.nix pkgs}/bin/i3_balance_workspace";
              };

              scratchpad = {
                "$mod+Shift+grave" = "move scratchpad";
                "$mod+grave" = "[class=.*] scratchpad show "; # toggles all scratchpad windows
              };

              media = {
                "XF86AudioRaiseVolume " = ponymix "increase 5";
                "XF86AudioLowerVolume" = ponymix "decrease 5";
                "XF86AudioMute" = ponymix "--sink toggle";
                "Scroll_Lock" = ponymix "--source toggle";
                "XF86AudioPlay" = playerctl "play";
                "XF86AudioPause" = playerctl "pause";
                "XF86AudioNext" = playerctl "next";
                "XF86AudioPrev" = playerctl "previous";
              };

              backlight = {
                "XF86MonBrightnessDown" = "exec xbacklight -dec 20";
                "XF86MonBrightnessUp" = "exec xbacklight -inc 20";
              };

              capture = {
                "Print" = "exec --no-startup-id ${cfg.screenshot.exec}";
              };
            };
          in
          foldl' lib.attrsets.unionOfDisjoint { } (attrValues groups);

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

            "$mod+h" = "focus left";
            "$mod+j" = "focus down";
            "$mod+k" = "focus up";
            "$mod+l" = "focus right";

            # Move position by mouse
            "$mouse_left" = "move position mouse"; # move container to current position of mouse cursor
            "$mouse_right" = "exec ${./scripts/draw-resize.sh}";
            "$mouse_wheel_up" = "move up 1 ppt";
            "$mouse_wheel_down" = "move down 1 ppt"; # scroll wheel down
            "$mouse_wheel_right" = "move right 1 ppt"; # scroll wheel right
            "$mouse_wheel_left" = "move left 1 ppt"; # scroll wheel right

            "$mod+r" = "mode default";
            "Escape" = "mode default";
            "Ctrl+c" = "mode default";
            "Ctrl+g" = "mode default";
          };
        };

        bars = lib.mkIf config.services.polybar.enable [ ]; # disable for polybar

        fonts = {
          names = [
            "pango:${themeCfg.fonts.mono.name} ${toString themeCfg.fonts.mono.size}px"
            "pango:${themeCfg.fonts.sans.name} ${toString themeCfg.fonts.sans.size}px"
            "FontAwesome"
          ];
          size = 10.0;
        };

        # colors = with config.colorScheme.colors; {
        #   focused = {
        #     border = "#${base02}";
        #     background = "#${base01}";
        #     text = "#${base05}";
        #     indicator = "#${base04}";
        #     childBorder = "#${base03}";
        #   };
        #   focusedInactive = {
        #     border = "#${base02}";
        #     background = "#${base01}";
        #     text = "#${base05}";
        #     indicator = "#${base03}";
        #     childBorder = "#${base02}";
        #   };
        #   unfocused = {
        #     border = "#${base01}";
        #     background = "#${base00}";
        #     text = "#${base04}";
        #     indicator = "#${base01}";
        #     childBorder = "#${base01}";
        #   };
        #   urgent = {
        #     border = "#${base08}";
        #     background = "#${base08}";
        #     text = "#${base00}";
        #     indicator = "#${base08}";
        #     childBorder = "#${base08}";
        #   };
        #   placeholder = {
        #     border = "#${base00}";
        #     background = "#${base00}";
        #     text = "#${base05}";
        #     indicator = "#${base00}";
        #     childBorder = "#${base00}";
        #   };
        #   background = "#${base00}";
        # };

        window = {
          border = 2;
          # commands = [ ];
          titlebar = false;
        };

        focus = {
          followMouse = false;
          # wrapping = "no";
          forceWrapping = false;
          mouseWarping = true;
          newWindow = "focus";
        };

        gaps = {
          # horizontal = 10;
          # vertical = 10;
          inner = 5;
          outer = 5;
          # Smart borders will draw borders on windows only if there is more than one window in a workspace.
          # This feature can also be enabled only if the gap size between window and screen edge is 0.
          # Possible values are: on, off, no_gaps
          smartBorders = "on";
        };

        floating = {
          border = 2;
          criteria = [
            { class = "1Password.*"; }
            { class = "Gcolor*"; }
            { class = "Gpick*"; }
            { class = "Pavucontrol"; }
            { class = "Qalculate.*"; }
            { class = "System76 Keyboard Configurator"; }
            { class = "ProcessManager"; }
            { class = "Thunar"; }
            { class = "blueman-manager"; }
            { class = "file-manager"; }
            { class = "kitty-floating"; }
            { class = "kitty-one"; }
            { class = "mpv"; }
            { class = "nm-connection-editor"; }
            { class = "notification*"; }
            { class = "obs"; }
            { class = "pop-up"; }
            { class = "(?i)syncthing"; }
            { class = "zoom"; }
            { title = "Artha"; }
            { title = "Screen Layout Editor"; } # i.e. arandr
            { title = "Calculator"; }
            { title = "Event Tester"; } # i.e. xev
            { title = "Steam.*"; }
            { title = "(?i)soundcloud"; }
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

        workspaceOutputAssign = [
          {
            workspace = "9";
            output = "nonprimary";
          }
          {
            workspace = "0";
            output = "nonprimary";
          }
        ];

        startup = [
          {
            command = getExe pkgs.i3-auto-layout;
            always = true;
            notification = false;
          }
          (mkIf (themeCfg.wallpaper != null) {
            command = "${config.programs.feh.package}/bin/feh --no-fehbg --bg-fill ${themeCfg.wallpaper}";
            always = true;
            notification = false;
          })
          (mkIf config.services.polybar.enable {
            command = "systemctl --user restart polybar";
            always = true;
            notification = false;
          })
          {
            command = "${./i3-focus-marker.sh}";
            always = true;
            notification = false;
          }
        ];

        defaultWorkspace = "workspace number 1";
        workspaceLayout = "default";
      };

      extraConfig =
        let
          colors = config.colorScheme.colors;
        in
        ''
          #=====================================
          # Variables
          #=====================================

          set $alt ${cfg.keysyms.alt}
          set $mod ${cfg.keysyms.mod}
          set $menu ${cfg.keysyms.menu}
          set $mouse_left ${cfg.keysyms.mouseButtonLeft}
          set $mouse_middle ${cfg.keysyms.mouseButtonMiddle}
          set $mouse_right ${cfg.keysyms.mouseButtonRight}
          set $mouse_wheel_down ${cfg.keysyms.mouseWheelDown}
          set $mouse_wheel_left ${cfg.keysyms.mouseWheelLeft}
          set $mouse_wheel_right ${cfg.keysyms.mouseWheelRight}
          set $mouse_wheel_up ${cfg.keysyms.mouseWheelUp}

          set $bar_height ${toString barHeight}

          set $base00 #${colors.base00}
          set $base01 #${colors.base01}
          set $base02 #${colors.base02}
          set $base03 #${colors.base03}
          set $base04 #${colors.base04}
          set $base05 #${colors.base05}
          set $base06 #${colors.base06}
          set $base07 #${colors.base07}
          set $base08 #${colors.base08}
          set $base09 #${colors.base09}
          set $base0A #${colors.base0A}
          set $base0B #${colors.base0B}
          set $base0C #${colors.base0C}
          set $base0D #${colors.base0D}
          set $base0E #${colors.base0E}
          set $base0F #${colors.base0F}

          set_from_resources $color0 i3wm.color0 #${colors.base00}
          set_from_resources $color1 i3wm.color1 #${colors.base08}
          set_from_resources $color2 i3wm.color2 #${colors.base0B}
          set_from_resources $color3 i3wm.color3 #${colors.base0A}
          set_from_resources $color4 i3wm.color4 #${colors.base0D}
          set_from_resources $color5 i3wm.color5 #${colors.base0E}
          set_from_resources $color6 i3wm.color6 #${colors.base0C}
          set_from_resources $color7 i3wm.color7 #${colors.base05}
          set_from_resources $color8 i3wm.color8 #${colors.base03}
          set_from_resources $color9 i3wm.color9 #${colors.base09}
          set_from_resources $color10 i3wm.color10 #${colors.base01}
          set_from_resources $color11 i3wm.color11 #${colors.base02}
          set_from_resources $color12 i3wm.color12 #${colors.base04}
          set_from_resources $color13 i3wm.color13 #${colors.base06}
          set_from_resources $color14 i3wm.color14 #${colors.base0F}
          set_from_resources $color15 i3wm.color15 #${colors.base07}

          #=====================================
          # General
          #=====================================

          include ${config.xdg.configHome}/i3/config.d/*.conf

          default_orientation auto

          #=====================================
          # Keybindings, cont.
          #=====================================

          bindsym --whole-window --border $mod+$mouse_wheel_up focus up
          bindsym --whole-window --border $mod+$mouse_wheel_down focus down
          bindsym --whole-window --border $mod+$mouse_wheel_left focus left
          bindsym --whole-window --border $mod+$mouse_wheel_right focus right

          #=====================================
          # Window rules
          #=====================================

          for_window [class="kitty-one"] move position center

          for_window [class="(?i)conky"] floating enable, move position mouse, move down $height px

          for_window [class="(?i)Qalculate"] floating enable, move position mouse, move down $height px

          for_window [class="^zoom$" title="^.*(?<!Zoom Meeting)$"] floating enable, move position center

          for_window [class="(?i)pavucontrol"] floating enable, move position mouse, move down $bar_height px

          #=====================================
          # Notifications
          #=====================================

          set $mode_notifications notification: [RET] action [+RET] context [n] close [K] close-all [p] history-pop [z] pause toggle [ESC] exit

          mode --pango_markup "$mode_notifications" {
              bindsym Return       exec "dunstctl action 0"        , mode "default"
              bindsym Shift+Return exec dunstctl context           , mode "default"
              bindsym k            exec dunstctl close             , mode "default"
              bindsym Shift+k      exec dunstctl close-all         , mode "default"
              bindsym z            exec dunstctl set-paused toggle , mode "default"
              bindsym n            exec dunstctl close
              bindsym p            exec dunstctl history-pop

              bindsym q mode "default"
              bindsym Escape mode "default"
              bindsym Ctrl+c mode "default"
              bindsym Ctrl+g mode "default"
          }

          #=====================================
          # Gaps
          #=====================================

          smart_gaps on

          set $gaps_inner_default ${toString configCfg.gaps.inner}
          set $gaps_outer_default ${toString configCfg.gaps.outer}

          set $mode_gaps        gaps> [o]uter [i]nner [0]reset [q]uit
          set $mode_gaps_outer  gaps outer> [-|+]all [j|k]current [BS|0]reset [q]uit
          set $mode_gaps_inner  gaps inner> [-|+]all [j|k]current [BS|0]reset [q]uit

          bindsym $mod+Shift+g mode "$mode_gaps"

          mode --pango_markup "$mode_gaps" {
              bindsym o          mode "$mode_gaps_outer"
              bindsym i          mode "$mode_gaps_inner"

              bindsym BackSpace  gaps outer current set $gaps_outer_default, gaps inner current set $gaps_inner_default, mode default
              bindsym 0          gaps outer all set $gaps_outer_default    , gaps inner all set $gaps_inner_default    , mode  default

              bindsym q            mode "default"
              bindsym Return       mode "$mode_gaps"
              bindsym Escape       mode "default"
              bindsym Ctrl+c       mode "default"
              bindsym Ctrl+g       mode "default"
          }

          mode --pango_markup "$mode_gaps_outer" {
              bindsym equal       gaps outer all plus 5
              bindsym minus       gaps outer all minus 5
              bindsym k           gaps outer current plus 5
              bindsym j           gaps outer current minus 5

              bindsym BackSpace   gaps current outer set $gaps_outer_default, mode default
              bindsym 0           gaps outer all set $gaps_outer_default    , mode default

              bindsym Tab         mode "$mode_gaps_inner"
              bindsym Return      mode "$mode_gaps"
              bindsym Escape      mode "default"
              bindsym Ctrl+c      mode "default"
              bindsym Ctrl+g      mode "default"
          }

          mode "$mode_gaps_inner" {
              bindsym equal       gaps inner all plus 5
              bindsym minus       gaps inner all minus 5
              bindsym k           gaps inner current plus 5
              bindsym j           gaps inner current minus 5

              bindsym BackSpace   gaps current inner set $gaps_inner_default, mode default
              bindsym 0           gaps all inner set $gaps_inner_default    , mode default

              bindsym Tab         mode "$mode_gaps_outer"
              bindsym Return      mode "$mode_gaps"
              bindsym Escape      mode "default"
              bindsym Ctrl+c      mode "default"
              bindsym Ctrl+g      mode "default"
          }

          #=====================================
          # Window size
          #=====================================

          set $mode_resize resize> [w]ider [n]arrower [s]horter [t]aller [=]balance [g]aps
          mode "$mode_resize" {
              bindsym w resize grow width 8 px or 1 ppt
              bindsym n resize shrink width 8 px or 1 ppt
              bindsym s resize shrink height 8 px or 1 ppt
              bindsym t resize grow height 8 px or 1 ppt

              bindsym Shift+w resize grow width 24 px or 3 ppt
              bindsym Shift+n resize shrink width 24 px or 3 ppt
              bindsym Shift+t resize grow height 24 px or 3 ppt
              bindsym Shift+s resize shrink height 24 px or 3 ppt

              bindsym h resize grow width 8 px or 1 ppt
              bindsym j resize shrink height 8 px or 1 ppt
              bindsym k resize grow height 8 px or 1 ppt
              bindsym l resize shrink width 8 px or 1 ppt

              bindsym Shift+h resize shrink width 24 px or 3 ppt
              bindsym Shift+j resize grow height 24 px or 3 ppt
              bindsym Shift+k resize shrink height 24 px or 3 ppt
              bindsym Shift+l resize grow width 24 px or 3 ppt

              bindsym $mod+h focus left
              bindsym $mod+j focus down
              bindsym $mod+k focus up
              bindsym $mod+l focus right

              bindsym $mouse_left move position mouse
              bindsym $mouse_right exec --no-startup-id ${./scripts/draw-resize.sh}
              bindsym $mouse_wheel_up move up 1 ppt
              bindsym $mouse_wheel_down move down 1 ppt
              bindsym $mouse_wheel_right move right 1 ppt
              bindsym $mouse_wheel_left move left 1 ppt

              bindsym g mode "$mode_gaps"
              bindsym = exec i3_balance_workspace;

              bindsym plus resize grow width 10 px or 2 ppt, resize grow height 10px or 2 ppt
              bindsym minus resize shrink width 10 px or 2 ppt, resize shrink height 10px or 2 ppt
              bindsym 0 floating enable, resize set width 50 ppt height 50 ppt, move position center, mode "default"
              bindsym 1 floating enable, resize set width 33 ppt height 97 ppt, move position 0 ppt $bar_height px, mode "default"
              bindsym 2 floating enable, resize set width 33 ppt height 97 ppt, move position 33 ppt $bar_height px, mode "default"
              bindsym 3 floating enable, resize set width 33 ppt height 97 ppt, move position 67 ppt $bar_height px, mode "default"

              bindsym $mod+r mode default
              bindsym Escape mode default
              bindsym Ctrl+c mode default
              bindsym Ctrl+g mode default
          }

          bindsym $mod+r mode "$mode_resize"
          bindsym $mod+n mode "$mode_notifications"

          #=====================================
          # Colors
          #=====================================

          # # class                 border   bg       fg       ind      child_border
          # client.focused          $color11 $color10 $color7  $color3  $color11
          # client.focused_inactive $color8  $color4  $color5  $color3  $color4
          # client.unfocused        $color3  $color0  $color4  $color3  $color3
          # client.urgent           $color2  $color15 $color5  $color15 $color15
          # client.placeholder      $color0  $color1  $color5  $color0  $color1
          # client.background       $color5

          # client.focused          #${colors.base02} #${colors.base01} #${colors.base05} #${colors.base0A} #${colors.base02}
          # client.focused_inactive #${colors.base03} #${colors.base04} #${colors.base05} #${colors.base03} #${colors.base04}
          # client.unfocused        #${colors.base03} #${colors.base00} #${colors.base04} #${colors.base03} #${colors.base03}
          # client.urgent           #${colors.base02} #${colors.base0F} #${colors.base05} #${colors.base0F} #${colors.base0F}
          # client.placeholder      #${colors.base00} #${colors.base01} #${colors.base05} #${colors.base00} #${colors.base01}
          # client.background       #${colors.base05}

          # Property Name         Border  BG      Text    Indicator Child Border
          client.focused          $base05 $base0D $base00 $base0D $base0C
          client.focused_inactive $base01 $base01 $base05 $base03 $base01
          client.unfocused        $base01 $base00 $base05 $base01 $base01
          client.urgent           $base08 $base08 $base00 $base08 $base08
          client.placeholder      $base00 $base00 $base05 $base00 $base00
          client.background       $base07
        '';
    };
  };
}
