{ config, lib, pkgs }:

with builtins;
with lib;
with lib.my;

let
  inherit (config.xsession.windowManager.i3.config) terminal;

  i3-input = prompt: limit: format:
    ''
      exec --no-startup-id "i3-input -P '${prompt}' -l ${limit} -F '${format}' -f 'pango:${config.my.fonts.mono.name} 14' '';

  # TODO access via flake via special args
  x-window-focus-close =
    pkgs.callPackage ../../../pkgs/x-window-focus-close { };

in {
  session = {
    "$mod+Shift+q" = "kill";
    # "$mod+Ctrl+Shift+q" = ''mode "$mode_kill"'';
    "$mod+Ctrl+q" = "exec --no-startup-id xkill";
    "--release $mod+$alt+q" =
      "exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";
    "$mod+w" = "exec --no-startup-id ${getExe x-window-focus-close}";
    "$mod+Ctrl+c" = "restart";
    "$mod+Shift+c" = "reload";
    "$mod+Shift+semicolon" = "exec --no-startup-id i3-input -P 'i3-msg: '";
    "Ctrl+$alt+Delete" =
      "exec --no-startup-id ${config.programs.urxvt.package}/bin/urxvt -e ${config.programs.btop.package}/bin/btop";
    # inspect current window properties
    # "--release $mod+i" = "exec ${
    #     pkgs.writeShellScript "xprop-hud" ''
    #       # toggling behavior
    #       pkill --full "$0" && exit 0

    #       eval "$(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowgeometry --shell)" || exit $?

    #       ${pkgs.xst}/bin/xst -a -w "$WINDOW" -e sh -c "
    #           ${pkgs.xorg.xprop}/bin/xprop -id '$WINDOW' -spy;
    #           "
    #     ''
    #   }";
  };

  fkeys = {
    "$mod+F1" = "exec --no-startup-id thunar";
    "$mod+F2" = ''
      exec --no-startup-id kitty --class kitty-floating vim -u NORC --noplugin -M -R "${config.xdg.configHome}/i3/config"'';
    "$mod+F6" =
      "exec --no-startup-id i3-input -F 'rename workspace to \"%s \"' -P 'New name: ''";
    "$mod+F9" = "exec --no-startup-id rofi-power";
  };

  clipboard = optionalAttrs config.services.clipmenu.enable {
    "$mod+Shift+backslash" =
      "exec --no-startup-id env CM_LAUNCHER=rofi clipmenu";
  };

  marks = {
    # read 1 character and mark the current window with this character
    "$mod+m" = ''exec i3-input -F 'mark --replace %s' -l 1 -P "Set mark: "'';
    "$mod+Shift+m" = ''exec i3-input -F 'mark --add %s' -l 1 -P "Add mark: "'';
    "$mod+Control+m" = ''exec i3-input -F 'unmark %s' -l 1 -P "Unmark: "'';
    "$mod+g" = ''exec i3-input -F '[con_mark="%s"] focus' -l 1 -P "Focus mark: "'';
    "$mod+Shift+g" = ''exec i3-input -F 'swap container with mark %s' -l 1 -P "Swap with mark: "'';
  };

  logs = {
    "$mod+Shift+s" =
      "exec kitty --title journalctl --class scratchpad -- bash -c 'journalctl --dmesg --follow --since=today --output=json | ${pkgs.lnav}/bin/lnav';";
  };

  browser = {
    "$mod+Shift+Return" = "exec ${config.modules.desktop.browsers.default}";
    "$mod+$alt+Return" = "exec ${config.modules.desktop.browsers.alternate}";
  } // optionalAttrs config.programs.qutebrowser.enable {
    "$mod+Ctrl+Return" =
      "exec RESOURCE_NAME=scratchpad ${config.programs.qutebrowser.package}/bin/qutebrowser";
  };

  editor = {
    "$mod+e" = ''exec ${pkgs.yad}/bin/yad --text "No editor is configured!"'';
  } // optionalAttrs config.programs.emacs.enable {
    "$mod+e" = "focus parent, exec emacs";
  } // optionalAttrs config.services.emacs.enable {
    "$mod+e" = "focus parent, exec emacsclient -c -a " " -n";
  } // optionalAttrs config.my.emacs.doom.enable {
    "--release $mod+$alt+n" =
      "exec org-capture"; # WM_NAME(STRING) = "doom-capture"
    "--release $mod+$alt+e" = "exec doom +everywhere";
  };

  terminal = {
    "$mod+Return" = "exec ${terminal}";
    "$mod+Shift+n" = "exec ${terminal} ${getExe pkgs.ranger}";
  };

  menus = let rofi = toExe config.programs.rofi;
  in mapAttrs' (keybind: exec:
    nameValuePair "--release ${keybind}" "exec --no-startup-id ${exec}") {
      "$mod+space" = "${rofi} -show combi -sidebar-mode true";
      "$mod+Shift+space" =
        "${rofi} -show window -modi window#windowcd -sidebar-mode true";
      "$mod+$alt+space" =
        "${rofi} -show emoji -modi emoji#file-browser-extended -sidebar-mode true";
      "$mod+semicolon" = "${rofi} -show run -modi run#drun -sidebar-mode true";
      "$mod+Shift+equal" = "${rofi} -show calc -modi calc";
      "$mod+Escape" = "rofi-power";
      "$mod+s" = "${pkgs.rofi-systemd}/bin/rofi-systemd";
      "$mod+a" = "${pkgs.rofi-pulse-select}/bin/rofi-pulse-select sink";
      "$mod+Shift+a" = "${pkgs.rofi-pulse-select}/bin/rofi-pulse-select source";
      "$mod+p" = "env REPOSITORY=patch-tech/patch ${rofi} -show gh -modi gh";
    };

  focusNeighbor = {
    "$mod+h" = "focus left";
    "$mod+j" = "focus down";
    "$mod+k" = "focus up";
    "$mod+l" = "focus right";
  };

  focusTree = {
    "$mod+Up" = "focus parent";
    "$mod+Down" = "focus child";
    "$mod+Left" = "focus prev sibling";
    "$mod+Right" = "focus next sibling";
  };

  focusMode = {
    "$mod+f" = "focus mode_toggle"; # toggle between floating and tiling
  };

  focusOutput = {
    "$mod+o" = "focus output next";
    "$mod+Shift+o" = "move output next";
  };

  focusWorkspaceAbsolute = {
    "$mod+1" = "workspace number $ws1";
    "$mod+2" = "workspace number $ws2";
    "$mod+3" = "workspace number $ws3";
    "$mod+4" = "workspace number $ws4";
    "$mod+5" = "workspace number $ws5";
    "$mod+6" = "workspace number $ws6";
    "$mod+7" = "workspace number $ws7";
    "$mod+8" = "workspace number $ws8";
    "$mod+9" = "workspace number $ws9";
    "$mod+0" = "workspace number $ws10";
  };

  focusWorkspaceRelative = {
    "$mod+Tab" = "workspace back_and_forth";
    # "$mod+Left" = "workspace prev";
    # "$mod+Right" = "workspace next";
    "$mod+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} focus";
    "$mod+bracketleft" = "workspace prev";
    "$mod+bracketright" = "workspace next";
  };

  moveWindow = {
    "$mod+Shift+h" = "move left 10 ppt";
    "$mod+Shift+j" = "move down 10 ppt";
    "$mod+Shift+k" = "move up 10 ppt";
    "$mod+Shift+l" = "move right 10 ppt";
    "$mod+shift+comma" = "move up; move left; mark h";
    "$mod+shift+period" = "move up; move right; mark l";
  };

  resize = {
    "$mod+comma" = "resize shrink width 32 px or 6 ppt";
    "$mod+period" = "resize grow width 32 px or 6 ppt";
  };

  move = {
    # Push
    "$mod+Ctrl+1" = "move container to workspace number $ws1";
    "$mod+Ctrl+2" = "move container to workspace number $ws2";
    "$mod+Ctrl+3" = "move container to workspace number $ws3";
    "$mod+Ctrl+4" = "move container to workspace number $ws4";
    "$mod+Ctrl+5" = "move container to workspace number $ws5";
    "$mod+Ctrl+6" = "move container to workspace number $ws6";
    "$mod+Ctrl+7" = "move container to workspace number $ws7";
    "$mod+Ctrl+8" = "move container to workspace number $ws8";
    "$mod+Ctrl+9" = "move container to workspace number $ws9";
    "$mod+Ctrl+0" = "move container to workspace number $ws10";
    "$mod+Ctrl+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} move";
    "$mod+Ctrl+Tab" = "move container to workspace back_and_forth";
    # Carry
    "$mod+Shift+bracketleft" =
      "move container to workspace prev, workspace prev";
    "$mod+Shift+bracketright" =
      "move container to workspace next, workspace next";
    "$mod+Shift+1" =
      "move container to workspace number $ws1, workspace number $ws1";
    "$mod+Shift+2" =
      "move container to workspace number $ws2, workspace number $ws2";
    "$mod+Shift+3" =
      "move container to workspace number $ws3, workspace number $ws3";
    "$mod+Shift+4" =
      "move container to workspace number $ws4, workspace number $ws4";
    "$mod+Shift+5" =
      "move container to workspace number $ws5, workspace number $ws5";
    "$mod+Shift+6" =
      "move container to workspace number $ws6, workspace number $ws6";
    "$mod+Shift+7" =
      "move container to workspace number $ws7, workspace number $ws7";
    "$mod+Shift+8" =
      "move container to workspace number $ws8, workspace number $ws8";
    "$mod+Shift+9" =
      "move container to workspace number $ws9, workspace number $ws9";
    "$mod+Shift+0" =
      "move container to workspace number $ws10; workspace number $ws10;";
    "$mod+Shift+Tab" =
      "move container to workspace back_and_forth, workspace back_and_forth;";
    "$mod+Shift+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} carry";
    # "$mod+Ctrl+minus" = "nop"; # reserved sequence
  };

  # Ctrl+Shift ~> per-output operations
  outputs = {
    "$mod+$alt+Shift+h" = "move workspace to output left";
    "$mod+$alt+Shift+j" = "move workspace to output down";
    "$mod+$alt+Shift+k" = "move workspace to output up";
    "$mod+$alt+Shift+l" = "move workspace to output right";

    "$mod+$alt+bracketleft" = "workspace prev_on_output";
    "$mod+$alt+bracketright" = "workspace next_on_output";

    "$mod+$alt+Shift+greater" = "move workspace to output primary";
    "$mod+$alt+Shift+less" = "move workspace to output nonprimary";
  };

  layout = {
    "$mod+Shift+r" =
      "exec --no-startup-id ${pkgs.i3-layout-manager}/bin/layout_manager";
    "$mod+Shift+f" = "floating toggle";
    "$mod+Ctrl+f" = "fullscreen toggle";
    "$mod+Shift+y" = "floating toggle; sticky toggle";
    "$mod+$alt+f" = "floating toggle; sticky toggle";
    "$mod+t" = "layout toggle split";
    "$mod+BackSpace" = "split toggle";
    "$mod+apostrophe" = "layout toggle stacking tabbed split";
    "$mod+c" = "layout stacking";
    "$mod+v" = "layout split";
    "$mod+b" = "layout tabbed";

    "$mod+equal" = "exec --no-startup-id ${
        getExe (pkgs.callPackage ./i3-balance-workspace.nix { })
      }";
  };

  scratchpad = {
    "$mod+Shift+grave" = "move scratchpad";
    "$mod+grave" =
      "[class=.*] scratchpad show "; # toggles all scratchpad windows
  };

  audio = let
    ponymix = args:
      "exec --no-startup-id ${getExe pkgs.ponymix} --notify ${args}";
  in {
    "XF86AudioRaiseVolume " = ponymix "--output increase 5";
    "XF86AudioLowerVolume" = ponymix "--output decrease 5";
    "XF86AudioMute" = ponymix "--output toggle";
    "Shift+XF86AudioRaiseVolume " = ponymix "--input increase 5";
    "Shift+XF86AudioLowerVolume" = ponymix "--input decrease 5";
    "Shift+XF86AudioMute" = ponymix "--input toggle";
  };

  media = let
    playerctl = args: "exec --no-startup-id ${getExe pkgs.playerctl} ${args}";
  in {
    "XF86AudioPlay" = playerctl "play";
    "XF86AudioPause" = playerctl "pause";
    "XF86AudioNext" = playerctl "next";
    "XF86AudioPrev" = playerctl "previous";
  };

  backlight = {
    "XF86MonBrightnessDown" = "exec xbacklight -dec 20";
    "XF86MonBrightnessUp" = "exec xbacklight -inc 20";
  };

  screenshot = optionalAttrs config.services.flameshot.enable {
    "--release Print" = "exec --no-startup-id flameshot gui";
  };

  bar = if config.services.polybar.enable then {
    "$mod+z" = "exec --no-startup-id ${../../../home/rofi/scripts/polybar.sh}";
  } else {
    "$mod+z" = "bar mode toggle";
  };
}
