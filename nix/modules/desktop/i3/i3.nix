{
  self,
  config,
  lib,
  pkgs,
  ...
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
  leftMouseButton = "button1";
  middleMouseButton = "button2";
  rightMouseButton = "button2";
  scrollWheelUp = "button4";
  scrollWheelDown = "button5";
  scrollWheelRight = "button6";
  scrollWheelLeft = "button7";

  playerctl = args: "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl ${args}";
  ponymix = args: "exec --no-startup-id ${pkgs.ponymix}/bin/ponymix ${args}";

  rofi = let
    toCommandLine = lib.cli.toGNUCommandLineShell rec {
      mkOptionName = k: "-${k}";
      mkList = k: v: lib.optionals (v != []) [(mkOptionName k) (lib.concatStringsSep "," v)];
    };
    in attrs: ''--release exec rofi ${toCommandLine attrs}''
  ;

  execType = with types; oneOf [path str];
in {
  options.modules.desktop.i3 = {
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
    programs.rofi.plugins = with pkgs; [rofi-calc rofi-emoji];

    xsession.windowManager.i3 = {
      config = lib.mkOptionDefault {
        modifier = super;

        keybindings = let
          groups = {
            session =
              {
                "${super}+Shift+q" = "kill";
                "${super}+Shift+x" = "--release exec ${pkgs.xdotool}/bin/xdotool selectwindow windowclose"; # alternatively, xkill
                "${super}+${alt}+q" = "exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";
                "${super}+Ctrl+c" = "restart";
                "${super}+Shift+c" = "reload";
                # "${super}+Shift+p" = ''exec --no-startup-id i3-msg exit'';
                "${super}+Shift+semicolon" = "exec --no-startup-id i3-input -P 'i3-msg: '";
                "${super}+F2;" = ''exec --no-startup-id i3-input -F 'rename workspace to "%s "' -P 'New name: ''''';
              }
              // optionalAttrs (!isNull cfg.locker.exec) {
                "${super}+Escape" = "exec --no-startup-id ${cfg.locker.exec}";
              };

            processManager = {
              "Ctrl+${alt}+Delete" = ''exec ${cfg.processManager.exec}'';
            };

            clipboard = lib.optionalAttrs config.services.clipmenu.enable {
              "${super}+Shift+backslash" = ''exec --no-startup-id env CM_LAUNCHER=rofi clipmenu'';
            };

            focusWindow = {
              "${super}+h" = "focus left";
              "${super}+j" = "focus down";
              "${super}+k" = "focus up";
              "${super}+l" = "focus right";
              "${super}+backslash" = "focus parent";
            };

            webBrowser = let
              chrome = findFirst (p: p.enable) programs.google-chrome [
                config.programs.google-chrome
                config.programs.google-chrome-beta
                config.programs.chromium
                config.programs.google-chrome-dev
                config.programs.vivaldi
                config.programs.brave
              ];

              linearChromeAppId = "bgdbmehlmdmddlgneophbcddadgknlpm";
            in {
              "${super}+Shift+Return" = ''exec google-chrome "--profile-directory=Profile 1"''; # work
              "${super}+${alt}+Return" = ''exec google-chrome "--profile-directory=Default"''; # personal
              "${super}+Shift+Ctrl+Return" = ''exec google-chrome "--profile-directory=Profile 1" --app-id=bgdbmehlmdmddlgneophbcddadgknlpm''; # linear
            };

            explorer = {
              "${super}+Shift+n" = ''exec kitty --class Ranger ${pkgs.ranger}/bin/ranger'';
              "${super}+Shift+e" = ''exec thunar'';
            };

            editor = {
              "${super}+e" = ''exec ${cfg.editor.exec}'';
            };

            terminal = {
              "${super}+Return" = "exec kitty";
              "${super}+Ctrl+Return" = "exec kitty --title kitty-one --single-instance";
            };

            menus = {
              "${super}+space" = rofi { show = "drun"; };
              "${super}+semicolon" = rofi { show = "run"; };
              "${super}+Shift+space" = rofi { show = "window"; modi = ["window" "windowcd"]; };
              "${super}+Shift+equal" = rofi { show = "calc"; };
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
              "${super}+Shift+Tab" = "move container to workspace back_and_forth";
              "${super}+Left" = "workspace prev";
              "${super}+Right" = "workspace next";
              "${super}+minus" = "exec --no-startup-id i3-next-workspace focus";
              "${super}+bracketleft" = "workspace prev";
              "${super}+bracketright" = "workspace next";
            };

            jumpWindow = {
              "${super}+comma" = "[con_mark=_prevFocus0] focus";
              "${super}+ctrl+comma" = "[con_mark=_prevFocus2] focus";
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
              "${super}+Shift+minus" = "exec --no-startup-id i3-next-workspace move";
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
              "${super}+${alt}+minus" = "exec --no-startup-id i3-next-workspace carry";
            };

            # Ctrl+Shift ~> per-output operations
            outputs = {
              "${super}+Ctrl+Shift+Tab" = "workspace next_on_output";
              "${super}+Ctrl+Shift+grave" = "workspace prev_on_output";

              "${super}+Ctrl+Shift+h" = "move workspace to output left";
              "${super}+Ctrl+Shift+j" = "move workspace to output down";
              "${super}+Ctrl+Shift+k" = "move workspace to output up";
              "${super}+Ctrl+Shift+l" = "move workspace to output right";

              "${super}+Ctrl+Shift+bracketleft" = "workspace prev_on_output";
              "${super}+Ctrl+Shift+bracketright" = "workspace next_on_output";

              "${super}+Ctrl+Shift+greater" = "move workspace to output primary";
              "${super}+Ctrl+Shift+less" = "move workspace to output nonprimary";
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
              "${super}+y" = "exec --no-startup-id ${pkgs.i3-layout-manager}/bin/layout_manager";
              "${super}+f" = "floating toggle";
              "${super}+t" = "layout toggle split";
              "${super}+Shift+t" = "layout toggle tabbed stacking split"; # TODO a mode would be more efficient
            };

            scratchpad = {
              "${super}+Shift+grave" = "move scratchpad";
              "${super}+grave" = "[class=.*] scratchpad show "; # toggles all scratchpad windows
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
          foldl' self.lib.unionOfDisjoint {} (attrValues groups);

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

        bars = lib.mkIf config.services.polybar.enable []; # disable for polybar

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
            {class = "1Password.*";}
            {class = "Gcolor*";}
            {class = "Gpick*";}
            {class = "Pavucontrol";}
            {class = "Qalculate.*";}
            {class = "System76 Keyboard Configurator";}
            {class = "ProcessManager";}
            {class = "Thunar";}
            {class = "blueman-manager";}
            {class = "file-manager";}
            {class = "kitty-floating";}
            {class = "kitty-one";}
            {class = "nm-connection-editor";}
            {class = "notification*";}
            {class = "obs";}
            {class = "pop-up";}
            {class = "(?i)syncthing";}
            {class = "zoom";}
            {title = "Artha";}
            {title = "Screen Layout Editor";} # i.e. arandr
            {title = "Calculator";}
            {title = "Event Tester";} # i.e. xev
            {title = "Steam.*";}
            {title = "doom-capture";}
          ];
        };

        assigns = {
          "1" = [];
          "2" = [];
          "3" = [];
          "4" = [];
          "5" = [];
          "6" = [];
          "7" = [];
          "8" = [];
          "9" = [{class = "Slack";}];
          "0" = [];
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
          (mkIf (!isNull themeCfg.wallpaper) {
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

      extraConfig = with config.colorScheme.colors; ''
        set $mod ${super}
        set $alt ${alt}
        set $bar_height ${toString barHeight}

        include ${config.xdg.configHome}/i3/config.d/*.conf

        default_orientation auto

        #=====================================
        # Keybindings, cont.
        #=====================================

        bindsym --whole-window --border ${super}+${scrollWheelUp} focus up
        bindsym --whole-window --border ${super}+${scrollWheelDown} focus down
        bindsym --whole-window --border ${super}+${scrollWheelLeft} focus left
        bindsym --whole-window --border ${super}+${scrollWheelRight} focus right

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

            bindsym # Move position by mouse
            bindsym button1 move position mouse
            bindsym button2 exec ${./scripts/draw-resize.sh}
            bindsym button4 move up 1 ppt
            bindsym button5 move down 1 ppt
            bindsym button6 move right 1 ppt
            bindsym button7 move left 1 ppt

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
        bindsym $mod+equal exec i3_balance_workspace;

        # The side buttons move the window around
        bindsym button9 move left
        bindsym button8 move right

        #################
        # client.focused
        # : A client which currently has the focus.
        #
        # client.focused_inactive
        # : A client which is the focused one of its container, but it does not have the focus at the moment.
        #
        # client.focused_tab_title
        # : Tab or stack container title that is the parent of the focused container but not directly focused. Defaults to focused_inactive if not specified and does not use the indicator and child_border colors.
        #
        # client.unfocused
        # : A client which is not the focused one of its container.
        #
        # client.urgent
        # : A client which has its urgency hint activated.
        #
        # client.placeholder
        # : Background and text color are used to draw placeholder window contents (when restoring layouts). Border and indicator are ignored.
        #
        # client.background
        # : Background color which will be used to paint the background of the client window on top of which the client will be rendered. Only clients which do not cover the whole area of this window expose the color. Note that this colorclass only takes a single color.
        #################
        # class                 border     backgr.    text       indicator  child_border
        client.focused          #${base02} #${base01} #${base05} #${base0A} #${base02}
        client.focused_inactive #${base03} #${base04} #${base05} #${base03} #${base04}
        client.unfocused        #${base03} #${base00} #${base04} #${base03} #${base03}
        client.urgent           #${base02} #${base0F} #${base05} #${base0F} #${base0F}
        client.placeholder      #${base00} #${base01} #${base05} #${base00} #${base01}
        client.background       #${base05}
        #################
      '';
    };
  };
}
