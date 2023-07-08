{ config
, lib
, pkgs
, ...
}:

with builtins;
with lib;
with lib.my;

let
  cfg = config.modules.desktop.i3;
  i3Cfg = config.xsession.windowManager.i3.config;
  themeCfg = config.modules.theme;
  rofiCfg = config.programs.rofi;
  polybarCfg = config.services.polybar;
  polybarCfg' = config.modules.polybar; # TODO config.my.polybar;
in
{
  xsession.windowManager.i3.config = {
    modifier = cfg.keysyms.mod;
    menu = mkIf rofiCfg.enable "${getPackageExe rofiCfg} -dmenu";
    keybindings = import ./keybindings.nix { inherit config pkgs lib; };
    bars = lib.mkIf polybarCfg.enable [ ]; # disable for polybar
    fonts = {
      names = [
        "pango:${themeCfg.fonts.mono.name} ${toString themeCfg.fonts.mono.size}px"
        "pango:${themeCfg.fonts.sans.name} ${toString themeCfg.fonts.sans.size}px"
        "FontAwesome"
      ];
      size = 10.0;
    };

    window = {
      border = 2;
      titlebar = false;
    };

    focus = {
      followMouse = false;
      forceWrapping = false;
      mouseWarping = true;
      newWindow = "focus"; # "smart" "urgent" "none"
      # Whether the window focus commands automatically wrap around the edge of containers. See https://i3wm.org/docs/userguide.html#_focus_wrapping
      # wrapping = "workspace";
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
      titlebar = false;
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
        { class = "mpv"; }
        { class = "feh"; }
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
        { title = "doom-capture"; }
        { title = "Yubico Authenticator"; }
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

    workspaceOutputAssign =
      (
        forEach (range 1 8)
          (n: {
            workspace = toString n;
            output = "primary";
          })
      )
      ++ [
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
      (mkIf (themeCfg.wallpaper != null) {
        command = "${config.programs.feh.package}/bin/feh --no-fehbg --bg-fill ${themeCfg.wallpaper}";
        always = true;
        notification = false;
      })
      # FIXME: processes are not cleaned up proplerly
      # {
      #   command = "${./i3-focus-marker.sh}";
      #   always = true;
      #   notification = false;
      # }
    ];
    defaultWorkspace = "workspace number $ws1";
    workspaceLayout = "default";
  };

  xsession.windowManager.i3.extraConfig =
    let
      colors = config.colorScheme.colors;
    in
    ''
      ################################################################################
      # Variables
      ################################################################################

      # keybindings
      set $alt ${cfg.keysyms.alt}
      set $mod ${cfg.keysyms.mod}
      set $mouse_left ${cfg.keysyms.mouseButtonLeft}
      set $mouse_middle ${cfg.keysyms.mouseButtonMiddle}
      set $mouse_right ${cfg.keysyms.mouseButtonRight}
      set $mouse_wheel_down ${cfg.keysyms.mouseWheelDown}
      set $mouse_wheel_left ${cfg.keysyms.mouseWheelLeft}
      set $mouse_wheel_right ${cfg.keysyms.mouseWheelRight}
      set $mouse_wheel_up ${cfg.keysyms.mouseWheelUp}

      # workspaces
      set $ws1 "1"
      set $ws2 "2"
      set $ws3 "3"
      set $ws4 "4"
      set $ws5 "5"
      set $ws6 "6"
      set $ws7 "7"
      set $ws8 "8"
      set $ws9 "9"
      set $ws10 "10"
      set $ws11 "11"
      set $ws12 "12"
      set $ws13 "13"
      set $ws14 "14"
      set $ws15 "15"
      set $ws16 "16"
      set $ws17 "17"
      set $ws18 "18"
      set $ws19 "19"

      # bars
      set $bar_height ${toString polybarCfg'.bars.top.height}

      # colors
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

      ################################################################################
      # General
      ################################################################################

      include ${config.xdg.configHome}/i3/config.d/*.conf

      default_orientation auto

      ################################################################################
      # Keybindings, cont.
      ################################################################################

      bindsym --whole-window --border $mod+$mouse_wheel_up focus up
      bindsym --whole-window --border $mod+$mouse_wheel_down focus down
      bindsym --whole-window --border $mod+$mouse_wheel_left focus left
      bindsym --whole-window --border $mod+$mouse_wheel_right focus right

      ################################################################################
      # Window rules
      ################################################################################

      for_window [class="(?i)conky"] floating enable, move position mouse, move down $height px
      for_window [class="(?i)Qalculate"] floating enable, move position mouse, move down $height px
      for_window [class="^zoom$" title="^.*(?<!Zoom Meeting)$"] floating enable, move position center
      for_window [class="(?i)pavucontrol"] floating enable, move position mouse, move down $bar_height px

      ################################################################################
      # Gaps
      ################################################################################

      smart_gaps on

      set $gaps_inner_default ${toString i3Cfg.gaps.inner}
      set $gaps_outer_default ${toString i3Cfg.gaps.outer}


      bindsym $mod+Shift+g mode "$mode_gaps"

      ################################################################################
      # Modes
      ################################################################################

      ### Notifications (dunst)

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

      ### Gaps

      set $mode_gaps        gaps> [o]uter [i]nner [0]reset [q]uit
      set $mode_gaps_outer  gaps outer> [-|+]all [j|k]current [BS|0]reset [q]uit
      set $mode_gaps_inner  gaps inner> [-|+]all [j|k]current [BS|0]reset [q]uit
      mode --pango_markup "$mode_gaps" {
          bindsym o            mode "$mode_gaps_outer"
          bindsym i            mode "$mode_gaps_inner"
          bindsym BackSpace    gaps outer current set $gaps_outer_default, gaps inner current set $gaps_inner_default, mode default
          bindsym 0            gaps outer all set $gaps_outer_default    , gaps inner all set $gaps_inner_default    , mode  default
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

      ################################################################################
      # Window size
      ################################################################################

      set $mode_resize resize> [w]ider [n]arrower [s]horter [t]aller [=]balance [g]aps
      mode "$mode_resize" {
          # Direction (fine)
          bindsym h resize grow width 8 px or 1 ppt
          bindsym j resize shrink height 8 px or 1 ppt
          bindsym k resize grow height 8 px or 1 ppt
          bindsym l resize shrink width 8 px or 1 ppt
          bindsym Left resize grow width 8 px or 1 ppt
          bindsym Down resize shrink height 8 px or 1 ppt
          bindsym Up resize grow height 8 px or 1 ppt
          bindsym Right resize shrink width 8 px or 1 ppt

          # Direction (coarse)
          bindsym Shift+h resize shrink width 24 px or 3 ppt
          bindsym Shift+j resize grow height 24 px or 3 ppt
          bindsym Shift+k resize shrink height 24 px or 3 ppt
          bindsym Shift+l resize grow width 24 px or 3 ppt
          bindsym Shift+Left resize shrink width 24 px or 3 ppt
          bindsym Shift+Down resize grow height 24 px or 3 ppt
          bindsym Shift+Up resize shrink height 24 px or 3 ppt
          bindsym Shift+Right resize grow width 24 px or 3 ppt

          # Percentages
          bindsym 1 resize set width 10 ppt, mode default
          bindsym 2 resize set width 20 ppt, mode default
          bindsym 3 resize set width 30 ppt, mode default
          bindsym 4 resize set width 40 ppt, mode default
          bindsym 5 resize set width 50 ppt, mode default
          bindsym 6 resize set width 60 ppt, mode default
          bindsym 7 resize set width 70 ppt, mode default
          bindsym 8 resize set width 80 ppt, mode default
          bindsym 9 resize set width 90 ppt, mode default
          bindsym Shift+1 resize set width 90 ppt, mode default
          bindsym Shift+2 resize set width 80 ppt, mode default
          bindsym Shift+3 resize set width 70 ppt, mode default
          bindsym Shift+4 resize set width 60 ppt, mode default
          bindsym Shift+5 resize set width 50 ppt, mode default
          bindsym Shift+6 resize set width 40 ppt, mode default
          bindsym Shift+7 resize set width 30 ppt, mode default
          bindsym Shift+8 resize set width 20 ppt, mode default
          bindsym Shift+9 resize set width 10 ppt, mode default

          bindsym $mod+h focus left
          bindsym $mod+j focus down
          bindsym $mod+k focus up
          bindsym $mod+l focus right

          bindsym f floating enable

          bindsym s floating enable, resize set width 66 ppt height 66 ppt, move position center, mode "default"
          bindsym a floating enable, resize set width 33 ppt height 66 ppt, move position center, move left 33 ppt, mode "default"
          bindsym d floating enable, resize set width 33 ppt height 66 ppt, move position center, move right 33 ppt, mode "default"
          bindsym q floating enable, resize set width 33 ppt height 66 ppt, move position center, move left 17 ppt, mode "default"
          bindsym e floating enable, resize set width 33 ppt height 66 ppt, move position center, move right 17 ppt, mode "default"

          bindsym equal exec --no-startup-id ${getExe (pkgs.callPackage ./i3-balance-workspace.nix {})};
          bindsym Shift+equal resize grow width 10 px or 5 ppt, resize grow height 10 px or 5 ppt
          bindsym minus resize shrink width 10 px or 5 ppt, resize shrink height 10 px or 5 ppt

          bindsym $mod+r mode default
          bindsym Escape mode default
          bindsym Ctrl+c mode default
          bindsym Ctrl+g mode default
      }

      bindsym $mod+r mode "$mode_resize"
      bindsym $mod+n mode "$mode_notifications"


    '';
  #
  # | Color Selector           | Description     |
  # | ------------------------ | --------------- |
  # | client.focused           | A client which currently has the focus.
  # | client.focused_inactive  | A client which is the focused one of its container, but it does not have the focus at the moment.
  # | client.focused_tab_title | Tab or stack container title that is the parent of the focused container but not directly focused. Defaults to focused_inactive if not specified and does not use the indicator and child_border colors.
  # | client.unfocused         | A client which is not the focused one of its container.
  # | client.urgent            | A client which has its urgency hint activated.
  # | client.placeholder       | Background and text color are used to draw placeholder window contents (when restoring layouts). Border and indicator are ignored.
  # | client.background        | Background color which will be used to paint the background of the client window on top of which the client will be rendered. Only clients which do not cover the whole area of this window expose the color. Note that this colorclass only takes a single color.
  #
  # NOTE: for window decorations, the color around the child window is the "child_border", and "border" color is only the two thin lines around the titlebar.
  #
  xsession.windowManager.i3.config.colors =
    with (mapAttrs (_: color: "#${color}") config.colorScheme.colors);
    {
      background = base08;
      focused = {
        background = base0D;
        border = base05;
        childBorder = base0C;
        indicator = base0D;
        text = base00;
      };
      focusedInactive = {
        background = base01;
        border = base01;
        childBorder = base01;
        indicator = base03;
        text = base05;
      };
      placeholder = {
        background = base00;
        border = base00;
        childBorder = base00;
        indicator = base00;
        text = base05;
      };
      unfocused = {
        background = base00;
        border = base01;
        childBorder = base01;
        indicator = base01;
        text = base05;
      };
      urgent = {
        background = base08;
        border = base08;
        childBorder = base08;
        indicator = base08;
        text = base00;
      };
    };
}
