{ config, lib, pkgs, ... }:

with builtins;
with lib;

let
  i3-auto-layout = import ./i3-auto-layout.nix pkgs; # callPackage?

  cfg = config.modules.desktop.i3;
  i3Cfg = config.xsession.windowManager.i3.config;
  themeCfg = config.modules.theme;
in
{
  programs.rofi.plugins = with pkgs; [ rofi-calc ]; # depended on below

  xsession.windowManager.i3.config = {
    modifier = cfg.keysyms.mod;
    keybindings = import ./keybindings.nix { inherit config pkgs lib; };
    bars = lib.mkIf config.services.polybar.enable [ ]; # disable for polybar
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
      wrapping = "workspace";
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
      titlebar = true;
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
      (forEach (range 1 8)
        (n: {
          workspace = toString n;
          output = "primary";
        })
      ) ++ [
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
        command = getExe i3-auto-layout;
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
      #=====================================
      # Variables
      #=====================================

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
      set $bar_height 40

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

      set $i3input ${./bin/rofi-i3-input}

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

      set $gaps_inner_default ${toString i3Cfg.gaps.inner}
      set $gaps_outer_default ${toString i3Cfg.gaps.outer}

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

          bindsym 1 resize set width 10 ppt, mode default
          bindsym 2 resize set width 20 ppt, mode default
          bindsym 3 resize set width 30 ppt, mode default
          bindsym 4 resize set width 40 ppt, mode default
          bindsym 5 resize set width 50 ppt, mode default
          bindsym Shift+1 resize set width 90 ppt, mode default
          bindsym Shift+2 resize set width 80 ppt, mode default
          bindsym Shift+3 resize set width 70 ppt, mode default
          bindsym Shift+4 resize set width 60 ppt, mode default
          bindsym Shift+5 resize set width 50 ppt, mode default

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
}
