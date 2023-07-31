{ config, lib, pkgs }:

with builtins;
with lib;
with lib.my;

let
  inherit (config.xsession.windowManager.i3.config) terminal;
in

foldl' attrsets.unionOfDisjoint { }
  (attrValues {

    session = {
      "$mod+Shift+q" = "kill";
      # "$mod+Ctrl+Shift+q" = ''mode "$mode_kill"'';
      "$mod+Ctrl+q" = "exec --no-startup-id xkill";
      "--release $mod+$alt+q" = "exec --no-startup-id kill -9 $(${getExe pkgs.xdotool} getwindowfocus getwindowpid)";
      "$mod+w" = "exec --no-startup-id ${getExe (pkgs.callPackage ../../../pkgs/x-window-focus-close.nix {})}";
      "$mod+Ctrl+c" = "restart";
      "$mod+Shift+c" = "reload";
      "$mod+Shift+semicolon" = "exec --no-startup-id i3-input -P 'i3-msg: '";
      "Ctrl+$alt+Delete" = ''exec --no-startup-id ${getPackageExe config.programs.urxvt} -e ${getPackageExe config.programs.btop}'';
    };

    fkeys = {
      "$mod+F1" = ''exec --no-startup-id thunar'';
      "$mod+F2" = ''exec --no-startup-id kitty --class kitty-floating less ${config.xdg.configHome}/i3/config'';
      "$mod+F6" = ''exec --no-startup-id i3-input -F 'rename workspace to "%s "' -P 'New name: ''''';
      "$mod+F9" = ''exec --no-startup-id rofi-power'';
    };

    clipboard = optionalAttrs config.services.clipmenu.enable {
      "$mod+Shift+backslash" = ''exec --no-startup-id env CM_LAUNCHER=rofi clipmenu'';
    };

    marks = {
      # read 1 character and mark the current window with this character
      "$mod+m" = ''exec i3-input -F 'mark --replace %s' -l 1 -P "Mark as: "'';
      # apostrophe a la vim. read 1 character and go to the window with the character
      "$mod+apostrophe" = ''exec i3-input -F '[con_mark="%s"] focus' -l 1 -P "Go to"'';
      "$mod+Shift+apostrophe" = ''exec i3-input -F 'swap container with mark %s' -l 1 -P "Swap with: "'';
      "$mod+Ctrl+apostrophe" = ''exec i3-input -F 'swap container with mark %s' -l 1 -P "Move to: "'';
    };

    logs = {
      "$mod+Shift+s" = ''exec --no-startup-id kitty --name systemlnav --class kitty-floating ${
        pkgs.writeShellScript "systemlnav" ''
           journalctl --dmesg --follow --since=today --output=json | ${getExe pkgs.lnav}
        ''
      }'';
    };

    browser = {
      "$mod+Shift+Return" = "exec ${config.modules.desktop.browsers.default}";
      "$mod+$alt+Return" = "exec ${config.modules.desktop.browsers.alternate}";
    };

    editor = {
      "$mod+e" =
        "focus parent, " +
        (if config.services.emacs.enable
        then ''exec emacsclient -c -a "" -n''
        else if config.programs.emacs.enable
        then ''exec emacs''
        else "nop");

      "$mod+$alt+e" =
        if !config.my.emacs.doom.enable
        then "nop"
        else if config.services.emacs.enable
        then ''emacsclient --eval "(emacs-everywhere)"''
        else "exec doom +everywhere";
    };

    terminal = {
      "$mod+Return" = ''exec ${terminal}'';
      "$mod+Shift+n" = ''exec ${terminal} ${getExe pkgs.ranger}'';
    };

    menus =
      let
        rofi = getPackageExe config.programs.rofi;
      in
      mapAttrs' (keybind: exec: nameValuePair "--release ${keybind}" "exec --no-startup-id ${exec}") {
        "$mod+space" = "${rofi} -show combi -sidebar-mode true";
        "$mod+Shift+space" = "${rofi} -show window -modi window#windowcd -sidebar-mode true";
        "$mod+$alt+space" = "${rofi} -show emoji -modi emoji#file-browser-extended -sidebar-mode true";
        "$mod+semicolon" = "${rofi} -show run -modi run#drun -sidebar-mode true";
        "$mod+Shift+equal" = "${rofi} -show calc -modi calc";
        "$mod+Escape" = "rofi-power";
        "$mod+s" = getExe pkgs.rofi-systemd;
        "$mod+a" = "${getExe pkgs.rofi-pulse-select} sink";
        "$mod+Shift+a" = "${getExe pkgs.rofi-pulse-select} source";
        "$mod+p" = "env REPOSITORY=patch-tech/patch ${rofi} -show gh -modi gh";
      };

    focusNeighbor = {
      "$mod+h" = "focus left";
      "$mod+j" = "focus down";
      "$mod+k" = "focus up";
      "$mod+l" = "focus right";
    };

    focusTree = {
      "$mod+z" = "focus prev sibling";
      "$mod+x" = "focus next sibling";
      "$mod+c" = "focus child";
      "$mod+v" = "focus parent";

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
      "$mod+Shift+Tab" = "move container to workspace back_and_forth";
      # "$mod+Left" = "workspace prev";
      # "$mod+Right" = "workspace next";
      "$mod+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} focus";
      "$mod+bracketleft" = "workspace prev";
      "$mod+bracketright" = "workspace next";
    };

    moveWindow = {
      "$mod+Shift+h" = "move left";
      "$mod+Shift+j" = "move down";
      "$mod+Shift+k" = "move up";
      "$mod+Shift+l" = "move right";
      "$mod+shift+g" = "move up; move left"; # Semi-hacky way to pull the current window out of the tab group.
    };

    moveWindowToWorkspace = {
      "$mod+Shift+1" = "move container to workspace number $ws1";
      "$mod+Shift+2" = "move container to workspace number $ws2";
      "$mod+Shift+3" = "move container to workspace number $ws3";
      "$mod+Shift+4" = "move container to workspace number $ws4";
      "$mod+Shift+5" = "move container to workspace number $ws5";
      "$mod+Shift+6" = "move container to workspace number $ws6";
      "$mod+Shift+7" = "move container to workspace number $ws7";
      "$mod+Shift+8" = "move container to workspace number $ws8";
      "$mod+Shift+9" = "move container to workspace number $ws9";
      "$mod+Shift+0" = "move container to workspace number $ws10";
      "$mod+Shift+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} move";
    };

    moveAndFocus = {
      "$mod+Ctrl+1" = "move container to workspace number $ws1; workspace number $ws1";
      "$mod+Ctrl+2" = "move container to workspace number $ws2; workspace number $ws2";
      "$mod+Ctrl+3" = "move container to workspace number $ws3; workspace number $ws3";
      "$mod+Ctrl+4" = "move container to workspace number $ws4; workspace number $ws4";
      "$mod+Ctrl+5" = "move container to workspace number $ws5; workspace number $ws5";
      "$mod+Ctrl+6" = "move container to workspace number $ws6; workspace number $ws6";
      "$mod+Ctrl+7" = "move container to workspace number $ws7; workspace number $ws7";
      "$mod+Ctrl+8" = "move container to workspace number $ws8; workspace number $ws8";
      "$mod+Ctrl+9" = "move container to workspace number $ws9; workspace number $ws9";
      "$mod+Ctrl+0" = "move container to workspace number $ws10; workspace number $ws10;";
      "$mod+Ctrl+Tab" = "move container to workspace back_and_forth; workspace back_and_forth;";
      "$mod+Ctrl+bracketleft" = "move container to workspace prev; workspace prev;";
      "$mod+Ctrl+bracketright" = "move container to workspace next; workspace next;";
      "$mod+Ctrl+grave" = "exec --no-startup-id ${./i3-next-workspace.sh} carry";
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
      "$mod+Shift+r" = "exec --no-startup-id ${pkgs.i3-layout-manager}/bin/layout_manager";
      "$mod+Shift+f" = "floating toggle";
      "$mod+Ctrl+f" = "fullscreen toggle";
      "$mod+Shift+y" = "floating toggle; sticky toggle";
      "$mod+t" = "layout toggle split";
      "$mod+BackSpace" = "split toggle";
      "$mod+Shift+t" = "layout toggle tabbed stacking split"; # TODO a mode would be more efficient
      "$mod+equal" = "exec --no-startup-id ${getExe (pkgs.callPackage ./i3-balance-workspace.nix {})}";
    };

    scratchpad = {
      "$mod+Shift+grave" = "move scratchpad";
      "$mod+grave" = "[class=.*] scratchpad show "; # toggles all scratchpad windows
    };

    audio =
      let
        ponymix = args: "exec --no-startup-id ${getExe pkgs.ponymix} --notify ${args}";
      in
      {
        "XF86AudioRaiseVolume " = ponymix "--output increase 5";
        "XF86AudioLowerVolume" = ponymix "--output decrease 5";
        "XF86AudioMute" = ponymix "--output toggle";
        "Shift+XF86AudioRaiseVolume " = ponymix "--input increase 5";
        "Shift+XF86AudioLowerVolume" = ponymix "--input decrease 5";
        "Shift+XF86AudioMute" = ponymix "--input toggle";
      };

    media =
      let
        playerctl = args: "exec --no-startup-id ${getExe pkgs.playerctl} ${args}";
      in
      {
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
      "--release Print" = ''exec --no-startup-id flameshot gui'';
    };

    bar =
      if config.services.polybar.enable then
        {
          "$mod+b" = "exec --no-startup-id ${../../../home/rofi/scripts/polybar.sh}";
        } else {
        "$mod+b" = "bar mode toggle";
      };
  })
