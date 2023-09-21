{ config, lib, pkgs, ... }:

with builtins;
with lib;
with lib.my;

let
  cfg = config.modules.desktop.i3;
  i3Cfg = config.xsession.windowManager.i3.config;
  themeCfg = config.modules.theme;
  rofiCfg = config.programs.rofi;
  rofiExe = toExe rofiCfg;
  polybarCfg = config.services.polybar;
  polybarCfg' = config.modules.polybar; # TODO config.my.polybar;
  barHeight = toString polybarCfg'.bars.top.height;

  bindings = import ./keybindings.nix { inherit config pkgs lib; };

  # i3-completion = pkgs.fetchFromGitHub {
  #   owner = "cornerman";
  #   repo = "i3-completion";
  #   rev = "01b9030500812403988ea78bd9bf2b47a7a0ae6d";
  #   hash = "sha256-efw45V0sfsPjSd8bYygDl+5oETgoRaRBnW6jNoIcpo0=";
  # };

in {
  xsession.windowManager.i3.config = {
    modifier = cfg.keysyms.mod;
    menu = mkIf rofiCfg.enable "${rofiExe} -dmenu";

    keybindings = foldl' attrsets.unionOfDisjoint { } (attrValues bindings);

    bars = lib.mkIf polybarCfg.enable [ ]; # disable for polybar

    # List of font names list used for window titles. Only FreeType fonts are supported.
    # The order here is important (e.g. icons font should go before the one used for text).
    fonts = {
      names = [ "FontAwesome" config.my.fonts.mono.name ];
      style = "Normal";
      size = 11.0;
    };

    window = {
      border = 4;
      titlebar = false;
      hideEdgeBorders = "none"; # none, vertical, horizontal, both, smart

      # List of commands that should be executed on specific windows (i.e. for_window)
      commands = [
        {
          criteria.class = "(?i)conky";
          command =
            "floating enable, move position mouse, move down ${barHeight} px";
        }
        {
          criteria.class = "(?i)nm-connection-editor";
          command = "floating enable, move position center";
        }
        {
          criteria.class = "(?i)qalculate";
          command =
            "floating enable, move position mouse, move down ${barHeight} px";
        }
        {
          criteria.class = "(?i)pavucontrol";
          command =
            "floating enable, move position mouse, move down ${barHeight} px";
        }
        {
          criteria.class = "^zoom$";
          criteria.title = "^.*(?<!Zoom Meeting)$"; # criteria.instance?
          command = "floating enable, sticky enable, move position center";
        }
        {
          criteria.class = "(?i)git-citool";
          command = "floating enable, move position mouse";
        }
        {
          criteria.class = "(?i)^emacs$";
          command = "move up, move left, resize set width 70 ppt";
        }
        {
          criteria.instance = "journalctl";
          criteria.class = "scratchpad";
          command =
            "move scratchpad, scratchpad show, move position center, resize set 80 ppt 50 ppt, move down 40 ppt";
        }
        {
          criteria.class = "kitty";
          command = "border normal"; # show window title
        }
        {
          criteria.instance = "^doom-capture$";
          command =
            "sticky enable, move position center, resize set 40 ppt 40 ppt";
        }
      ] ++ (forEach [
        { window_role = "^pop-up$"; }
        { class = "obsidian"; }
        { class = "^scratchpad$"; }
        { title = "^scratchpad$"; }
      ] (criteria: {
        inherit criteria;
        command = "move scratchpad, scratchpad show";
      }));
    };

    focus = {
      followMouse = false;
      forceWrapping = false;
      mouseWarping = false;
      newWindow = "focus"; # "smart" "urgent" "none"
      # Whether the window focus commands automatically wrap around the edge of containers. See https://i3wm.org/docs/userguide.html#_focus_wrapping
      # wrapping = "workspace";
    };

    gaps = {
      top = 4;
      left = 4;
      right = 4;
      bottom = 4;
      smartBorders = "off";
    };

    floating = { # uses for_window
      titlebar = false;
      border = 3;
      criteria = [
        { class = "(?i)1password.*"; }
        { class = "(?i)gcolor*"; }
        { class = "(?i)gpick*"; }
        { class = "(?i)pavucontrol"; }
        { class = "(?i)qalculate"; }
        { class = "(?i)xarchiver"; }
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
        { class = "(?i)xmessage"; }
        { class = "(?i)yad"; }
        { class = "(?i)zenity"; }
        { title = "(?i)artha"; }
        { title = "NVIDIA Settings"; }
        { title = "Screen Layout Editor"; } # i.e. arandr
        { title = "Calculator"; }
        { title = "Event Tester"; } # i.e. xev
        { title = "(?i)yubico authenticator"; }
        { title = "^Emacs Everywhere ::"; }
        { class = "^i3-floating$"; } # generic
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
      "output primary" = [{
        class = "^zoom$";
        title = "^.*(?<!Zoom Meeting)$";
      }];
    };

    workspaceOutputAssign = (forEach (range 1 8) (n: {
      workspace = toString n;
      output = "primary";
    })) ++ [
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
        command =
          "${config.programs.feh.package}/bin/feh --no-fehbg --bg-fill ${themeCfg.wallpaper}";
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

  xsession.windowManager.i3.extraConfig = let
    colors = config.colorScheme.colors;

    modeCommonFocus = ''
      bindsym $mod+h focus left
      bindsym $mod+j focus down
      bindsym $mod+k focus up
      bindsym $mod+l focus right
    '';
    modeCommonEscape = ''
      bindsym Escape mode default
      bindsym Ctrl+c mode default
      bindsym Ctrl+g mode default
    '';
    # modeStr = name: { title ? name, enableMarkup ? true, extraConfig ? "" }: ''
    #   set $$${name} ${title}
    #   mode ${optionalString enableMarkup "--pango_markup "} "$$${name}" {
    #     ${modeCommonEscape}
    #     ${extraConfig}
    #   }
    # '';

    mkBinding = { keysym ? null, keycode ? null, command ? null, exec ? null
      , noStartupId ? false, release ? false, wholeWindow ? false
      , excludeTitlebar ? false }:
      assert (keysym != null) == (keycode == null);
      assert noStartupId -> exec != null; ''
        bindsym
      '';

    mkBindings = bindings:
      pipe [

      ];
    mkMode = name: description: keysym: bindings:
      let variable = "$mode_${name}";
      in ''
        set ${variable} ${name}> ${description}
        mode "${variable}" {
            ${strings.concatLines modeBindings}
            # common mode bindings
            ${modeCommonEscape}
        }
        bindsym ${keysym} mode "${modeReference}"
      '';
  in ''
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

    # bars
    set $bar_height ${barHeight}

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

    show_marks yes
    default_orientation auto

    for_window [all] title_window_icon on
    for_window [all] title_window_icon padding 3px

    ################################################################################
    # Keybindings, cont.
    ################################################################################

    bindsym --whole-window --border $mod+$mouse_wheel_up focus up
    bindsym --whole-window --border $mod+$mouse_wheel_down focus down
    bindsym --whole-window --border $mod+$mouse_wheel_left focus left
    bindsym --whole-window --border $mod+$mouse_wheel_right focus right

    ################################################################################
    # Gaps
    ################################################################################

    smart_gaps on

    set $gaps_inner_default ${toString i3Cfg.gaps.inner}
    set $gaps_outer_default ${toString i3Cfg.gaps.outer}

    ################################################################################
    # Notifications
    ################################################################################

    ${optionalString config.services.dunst.enable ''
      # dunst
      set $mode_notifications notification: [RET] action [+RET] context [n] close [K] close-all [p] history-pop [z] pause toggle [ESC] exit
      bindsym $mod+n mode "$mode_notifications"
      mode "$mode_notifications" {
          bindsym Return       exec "dunstctl action 0"        , mode "default"
          bindsym Shift+Return exec dunstctl context           , mode "default"
          bindsym k            exec dunstctl close             , mode "default"
          bindsym Shift+k      exec dunstctl close-all         , mode "default"
          bindsym z            exec dunstctl set-paused toggle , mode "default"
          bindsym n            exec dunstctl close
          bindsym p            exec dunstctl history-pop

          ${modeCommonEscape}
      }
    ''}

    ${optionalString config.my.deadd.enable ''
      # deadd
      set $mode_notifications notification: [RET] action [+RET] context [n] close [K] close-all [p] history-pop [z] pause toggle [ESC] exit
      bindsym $mod+n exec --no-startup-id deadd-toggle
    ''}

    ################################################################################
    # Modes
    ################################################################################

    ### Gaps

    set $mode_gaps        gaps> [o]uter [i]nner [0]reset [q]uit
    set $mode_gaps_outer  gaps outer> [-|+]all [j|k]current [BS|0]reset [q]uit
    set $mode_gaps_inner  gaps inner> [-|+]all [j|k]current [BS|0]reset [q]uit
    mode "$mode_gaps" {
        bindsym o            mode "$mode_gaps_outer"
        bindsym i            mode "$mode_gaps_inner"
        bindsym BackSpace    gaps outer current set $gaps_outer_default, gaps inner current set $gaps_inner_default, mode default
        bindsym 0            gaps outer all set $gaps_outer_default    , gaps inner all set $gaps_inner_default    , mode  default
        bindsym q            mode "default"
        ${modeCommonEscape}
    }
    mode "$mode_gaps_outer" {
        bindsym equal       gaps outer all plus 5
        bindsym minus       gaps outer all minus 5
        bindsym k           gaps outer current plus 5
        bindsym j           gaps outer current minus 5
        bindsym BackSpace   gaps current outer set $gaps_outer_default, mode default
        bindsym 0           gaps outer all set $gaps_outer_default    , mode default
        bindsym Tab         mode "$mode_gaps_inner"
        bindsym Return      mode "$mode_gaps"
        ${modeCommonEscape}
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
        ${modeCommonEscape}
    }

    ################################################################################
    # Window size
    ################################################################################

    set $mode_resize resize> [w]ider [n]arrower [s]horter [t]aller [=]balance [g]aps
    bindsym $mod+r mode "$mode_resize"
    mode "$mode_resize" {
        # Direction (fine)
        bindsym h     resize grow   width  8 px or 1 ppt
        bindsym j     resize shrink height 8 px or 1 ppt
        bindsym k     resize grow   height 8 px or 1 ppt
        bindsym l     resize shrink width  8 px or 1 ppt
        bindsym Left  resize grow   width  8 px or 1 ppt
        bindsym Down  resize shrink height 8 px or 1 ppt
        bindsym Up    resize grow   height 8 px or 1 ppt
        bindsym Right resize shrink width  8 px or 1 ppt

        # Direction (coarse)
        bindsym Shift+h     resize grow   width  24 px or 4 ppt
        bindsym Shift+j     resize shrink height 24 px or 4 ppt
        bindsym Shift+k     resize grow   height 24 px or 4 ppt
        bindsym Shift+l     resize shrink width  24 px or 4 ppt
        bindsym Shift+Left  resize shrink width  24 px or 4 ppt
        bindsym Shift+Down  resize grow   height 24 px or 4 ppt
        bindsym Shift+Up    resize shrink height 24 px or 4 ppt
        bindsym Shift+Right resize grow   width  24 px or 4 ppt

        # Percentages
        bindsym 1       resize set 90 ppt, mode default
        bindsym 2       resize set 80 ppt, mode default
        bindsym 3       resize set 70 ppt, mode default
        bindsym 4       resize set 60 ppt, mode default
        bindsym 5       resize set 50 ppt, mode default
        bindsym 6       resize set 40 ppt, mode default
        bindsym 7       resize set 30 ppt, mode default
        bindsym 8       resize set 20 ppt, mode default
        bindsym 9       resize set 10 ppt, mode default
        bindsym Shift+9 resize set 90 ppt, mode default
        bindsym Shift+8 resize set 80 ppt, mode default
        bindsym Shift+7 resize set 70 ppt, mode default
        bindsym Shift+6 resize set 60 ppt, mode default
        bindsym Shift+5 resize set 50 ppt, mode default
        bindsym Shift+4 resize set 40 ppt, mode default
        bindsym Shift+3 resize set 30 ppt, mode default
        bindsym Shift+2 resize set 20 ppt, mode default
        bindsym Shift+1 resize set 10 ppt, mode default

        bindsym f floating enable
        bindsym s floating enable, resize set 66 ppt 66 ppt, move position center, mode "default"
        bindsym a floating enable, resize set 33 ppt 66 ppt, move position center, move left 33 ppt, mode "default"
        bindsym d floating enable, resize set 33 ppt 66 ppt, move position center, move right 33 ppt, mode "default"
        bindsym q floating enable, resize set 33 ppt 66 ppt, move position center, move left 17 ppt, mode "default"
        bindsym e floating enable, resize set 33 ppt 66 ppt, move position center, move right 17 ppt, mode "default"

        bindsym equal exec --no-startup-id ${
          getExe (pkgs.callPackage ./i3-balance-workspace.nix { })
        };
        bindsym Shift+equal resize grow width 10 px or 5 ppt, resize grow height 10 px or 5 ppt
        bindsym minus resize shrink width 10 px or 5 ppt, resize shrink height 10 px or 5 ppt

       ${modeCommonFocus}
       ${modeCommonEscape}
    }

    ################################################################################
    # Killing things
    ################################################################################

    set $mode_kill kill <${nerdfonts.md.keyboard_return}|f> <z|x|c|v>
    set $mode_kill_focused kill:focused> [w]orkspace, [f]loating, [c]lass, [r]ole, [t]itle

    mode "$mode_kill" {
       bindsym f mode "$mode_kill_focused"

       bindsym z focus prev sibling, kill, mode default
       bindsym x focus next sibling, kill, mode default
       bindsym c focus child, kill, mode default
       bindsym v focus parent, kill, mode default

       bindsym $mod+z focus prev sibling
       bindsym $mod+x focus next sibling
       bindsym $mod+c focus child
       bindsym $mod+v focus parent

       ${modeCommonFocus}
       ${modeCommonEscape}
    }

    mode "$mode_kill_focused" {
       bindsym w [workspace=__focused__] kill, mode default
       bindsym c [class=__focused__] kill, mode default
       bindsym r [role=__focused__] kill, mode default
       bindsym t [title=__focused__] kill, mode default

       ${modeCommonFocus}
       ${modeCommonEscape}
    }

    bindsym $mod+q mode "$mode_kill"

    ################################################################################
    # Marks menu
    ################################################################################

    set $mode_mark marks: [l]ist; [a]dd [r]eplace [u]nmark; [m]ove [s]wap [f]ocus [k]ill; show [y]es [n]o
    mode "$mode_mark" {
      bindsym l exec i3-marks-dmenu                                                     ; mode default
      bindsym u exec i3-marks-unmark                                                    ; mode default
      bindsym r exec i3-input -F 'mark --replace %s' -l 1 -P "mark replace"             ; mode default
      bindsym a exec i3-input -F 'mark --add %s' -l 1 -P "mark add"                     ; mode default
      bindsym A exec i3-input -F 'mark --add --toggle %s' -l 1 -P "toggle"              ; mode default
      bindsym m exec i3-input -F 'move window to mark %s' -l 1 -P "move window"         ; mode default
      bindsym M exec i3-input -F 'move container to mark %s' -l 1 -P "move container"   ; mode default
      bindsym f exec i3-input -F '[con_mark="%s"] fous' -l 1 -P "focus"                 ; mode default
      bindsym s exec i3-input -F 'swap container with %s' -l 1 -P "swap container with" ; mode default
      bindsym k exec i3-input -F '[con_mark="^%s$"] kill' -l 1 -P "kill"                ; mode default

      ${modeCommonEscape}
    }
    bindsym $mod+$alt+m mode "$mode_mark"

    ################################################################################
    # Window rules
    ################################################################################

    # https://github.com/ValveSoftware/steam-for-linux/issues/1040
    for_window [class="^Steam$" title="^Friends$"] floating enable
    for_window [class="^Steam$" title="Steam - News"] floating enable
    for_window [class="^Steam$" title=".* - Chat"] floating enable
    for_window [class="^Steam$" title="^Settings$"] floating enable
    for_window [class="^Steam$" title=".* - event started"] floating enable
    for_window [class="^Steam$" title=".* CD key"] floating enable
    for_window [class="^Steam$" title="^Steam - Self Updater$"] floating enable
    for_window [class="^Steam$" title="^Screenshot Uploader$"] floating enable
    for_window [class="^Steam$" title="^Steam Guard - Computer Authorization Required$"] floating enable
    for_window [title="^Steam Keyboard$"] floating enable

    ################################################################################
    # Misc
    ################################################################################


    no_focus [title="^i3-spy"]
    for_window [title="^i3-spy"] floating enable, sticky enable, move to mark i3-spy-target
    bindsym $mod+F3 --release mark i3-spy-taret; exec --no-startup-id ${
      pkgs.writeShellScript "i3-spy" ''
        if [[ $# == 0 ]]; then
          exec ${pkgs.xst}/bin/xst -T i3-spy -g "64x64" "$0" -
        fi

        i3-msg -t get_tree --raw | jq '.. | objects | select(.focused == true)'

        while read -r event; do
          echo -e '\0033\0143'
          jq 'select(.change == "focus").container' <<<"$event"
        done < <(i3-msg -t subscribe -m '["window"]')
      ''
    };

    ################################################################################
    # Includes
    ################################################################################

    include config.d/*.conf
    include `hostname`.conf
  '';

  home.packages = with pkgs; [
    (writeShellScriptBin "i3-cmd" ''
      flags=(-t command)
      while [[ $# -gt 0 ]]; do
        case $1 in
        -h | --help)
          echo "usage: $(basename "$0") [-q] [-v] [-r] [-s] command..."
          exit 0
          ;;
        -v | --verbose | -q | --quiet | -r | --raw)
          flags+=("$1")
          shift
          ;;
        -s | --socket)
          flags+=("$1" "$2")
          shift 2
          ;;
        -*)
          echo "unrecoginized flag: $1" >&2
          exit 1
          ;;
        *) break ;;
        esac
      done
      exec i3-msg "''${flags[@]}" "$*"
    '')
    (writeShellScriptBin "i3-marks-dmenu" ''
      i3-msg -t get_marks |
      ${getExe pkgs.jq} -r '.[]' |
      ${i3Cfg.menu} -p "mark" -no-custom "$@"
    '')
    (writeShellScriptBin "i3-marks-unmark" ''
      for mark in $(i3-marks-dmenu -multi-select); do
        i3-msg "unmark $mark"
      done
    '')
    # (writeShellScriptBin "i3-focus-or" ''
    #   usage() {
    #     echo "usage: $(basename "$0") <criteria> <command> [args...]"
    #   }
    #   if [[ $1 == (-h|--help) ]]; then
    #     usage
    #     exit 0
    #   elif [[ $# -lt 2 ]]; then
    #     usage
    #     exit 1
    #   fi
    #   criteria=$1
    #   shift
    #   if ! i3-msg "$(printf '[%s] focus' "$criteria")"; then
    #     i3-msg "exec $*"
    #   fi
    #   '')
  ];

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
    with (mapAttrs (_: color: "#${color}") config.colorScheme.colors); {
      background = base08;
      focused = {
        background = base02;
        border = base02;
        childBorder = base02;
        indicator = base0A;
        text = base00;
      };
      focusedInactive = {
        background = base00;
        border = base00;
        childBorder = base00;
        indicator = base01;
        text = base03;
      };
      placeholder = {
        background = base00;
        border = base00;
        childBorder = base00;
        indicator = base01;
        text = base03;
      };
      unfocused = {
        background = base00;
        border = base01;
        childBorder = base01;
        indicator = base01;
        text = base03;
      };
      urgent = {
        background = base09;
        border = base09;
        childBorder = base09;
        indicator = base09;
        text = base00;
      };
    };
}
