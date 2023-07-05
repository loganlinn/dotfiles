{ config, lib, pkgs, ... }:

with builtins;
with lib;

let

  cfg = config.modules.desktop.i3;

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

in

foldl' attrsets.unionOfDisjoint { } (attrValues {

  session = {
    "$mod+Shift+q" = "kill";
    "--release $mod+Shift+x" = "exec --no-startup-id ${pkgs.xdotool}/bin/xdotool selectwindow windowclose"; # alternatively, xkill
    "--release $mod+$alt+q" = "exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";
    "$mod+Ctrl+c" = "restart";
    "$mod+Shift+c" = "reload";
    # "$mod+Shift+p" = ''exec --no-startup-id i3-msg exit'';
    "$mod+Shift+semicolon" = "exec --no-startup-id i3-input -P 'i3-msg: '";
    "$mod+F1" = ''exec --no-startup-id thunar'';
    "$mod+F2" = ''exec --no-startup-id kitty bat ${config.xdg.configHome}/i3/config'';
    "$mod+F6" = ''exec --no-startup-id i3-input -F 'rename workspace to "%s "' -P 'New name: ''''';
    "$mod+F9" = ''exec --no-startup-id rofi-power'';
  };

  processManager = {
    "Ctrl+$alt+Delete" = ''exec ${cfg.processManager.exec}'';
  };

  clipboard = optionalAttrs config.services.clipmenu.enable {
    "$mod+Shift+backslash" = ''exec --no-startup-id env CM_LAUNCHER=rofi clipmenu'';
  };

  focusWindow = {
    "$mod+a" = "focus parent";
    "$mod+d" = "focus child";
    "$mod+f" = "focus mode_toggle"; # toggle between floating and tiling
    "$mod+z" = "focus prev sibling";
    "$mod+x" = "focus next sibling";
    "$mod+o" = "focus output next";
    "$mod+h" = "focus left";
    "$mod+j" = "focus down";
    "$mod+k" = "focus up";
    "$mod+l" = "focus right";
  };

  marks = {
    # read 1 character and mark the current window with this character
    "$mod+m" = ''exec i3-input -F 'mark --replace %s' -l 1 -P "Mark: "'';
    # read 1 character and go to the window with the character
    "$mod+g" = ''exec i3-input -F '[con_mark="%s"] focus' -l 1 -P "Goto: "'';
  };

  webBrowser = {
    "$mod+Shift+Return" = "exec ${config.modules.desktop.browsers.default}";
    "$mod+$alt+Return" = "exec ${config.modules.desktop.browsers.alternate}";
  };

  explorer = {
    "$mod+Shift+n" = ''exec --no-startup-id kitty --class Ranger ${pkgs.ranger}/bin/ranger'';
  };

  editor = {
    "$mod+e" = ''exec ${cfg.editor.exec}'';
  };

  terminal = {
    "$mod+Return" = "exec kitty";
  };

  menus = mapAttrs'
    (keys: exec: { name = "--release ${keys}"; value = "exec --no-startup-id ${exec}"; })
    {
      "$mod+space" = rofi "combi" { sidebar-mode = true; };
      "$mod+semicolon" = rofi "run" { modi = [ "run" "drun" ]; };
      "$mod+apostrophe" = rofi "window" { modi = [ "window" "windowcd" ]; };
      "$mod+Shift+apostrophe" = rofi "windowcd" { modi = [ "window" "windowcd" ]; };
      "$mod+Shift+equal" = rofi "calc" { };
      "$mod+Escape" = "rofi-power"; # see nix/home/rofi module
      "$mod+s" = getExe pkgs.rofi-systemd;
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
    "$mod+Left" = "workspace prev";
    "$mod+Right" = "workspace next";
    "$mod+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} focus";
    "$mod+bracketleft" = "workspace prev";
    "$mod+bracketright" = "workspace next";
  };

  moveWindowPosition = {
    "$mod+Shift+h" = "move left";
    "$mod+Shift+j" = "move down";
    "$mod+Shift+k" = "move up";
    "$mod+Shift+l" = "move right";
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
    "$mod+Shift+Ctrl+1" = "move container to workspace number $ws11";
    "$mod+Shift+Ctrl+2" = "move container to workspace number $ws12";
    "$mod+Shift+Ctrl+3" = "move container to workspace number $ws13";
    "$mod+Shift+Ctrl+4" = "move container to workspace number $ws14";
    "$mod+Shift+Ctrl+5" = "move container to workspace number $ws15";
    "$mod+Shift+Ctrl+6" = "move container to workspace number $ws16";
    "$mod+Shift+Ctrl+7" = "move container to workspace number $ws17";
    "$mod+Shift+Ctrl+8" = "move container to workspace number $ws18";
    "$mod+Shift+Ctrl+9" = "move container to workspace number $ws19";
    "$mod+Shift+Ctrl+0" = "move container to workspace number $ws20";
    "$mod+Shift+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} move";
  };

  carryWindowToWorkspace = {
    "$mod+$alt+1" = "move container to workspace number $ws1; workspace number $ws1";
    "$mod+$alt+2" = "move container to workspace number $ws2; workspace number $ws2";
    "$mod+$alt+3" = "move container to workspace number $ws3; workspace number $ws3";
    "$mod+$alt+4" = "move container to workspace number $ws4; workspace number $ws4";
    "$mod+$alt+5" = "move container to workspace number $ws5; workspace number $ws5";
    "$mod+$alt+6" = "move container to workspace number $ws6; workspace number $ws6";
    "$mod+$alt+7" = "move container to workspace number $ws7; workspace number $ws7";
    "$mod+$alt+8" = "move container to workspace number $ws8; workspace number $ws8";
    "$mod+$alt+9" = "move container to workspace number $ws9; workspace number $ws9";
    "$mod+$alt+0" = "move container to workspace number $ws10; workspace number $ws10;";
    "$mod+$alt+Ctrl+1" = "move container to workspace number $ws11; workspace number $ws11";
    "$mod+$alt+Ctrl+2" = "move container to workspace number $ws12; workspace number $ws12";
    "$mod+$alt+Ctrl+3" = "move container to workspace number $ws13; workspace number $ws13";
    "$mod+$alt+Ctrl+4" = "move container to workspace number $ws14; workspace number $ws14";
    "$mod+$alt+Ctrl+5" = "move container to workspace number $ws15; workspace number $ws15";
    "$mod+$alt+Ctrl+6" = "move container to workspace number $ws16; workspace number $ws16";
    "$mod+$alt+Ctrl+7" = "move container to workspace number $ws17; workspace number $ws17";
    "$mod+$alt+Ctrl+8" = "move container to workspace number $ws18; workspace number $ws18";
    "$mod+$alt+Ctrl+9" = "move container to workspace number $ws19; workspace number $ws19";
    "$mod+$alt+minus" = "exec --no-startup-id ${./i3-next-workspace.sh} carry";
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
    "$mod+y" = "exec --no-startup-id ${pkgs.i3-layout-manager}/bin/layout_manager";
    "$mod+Shift+f" = "floating toggle";
    "$mod+Shift+p" = "floating toggle; sticky toggle"; # "pin"
    "$mod+F11" = "fullscreen toggle";
    "$mod+t" = "layout toggle split";
    "$mod+BackSpace" = "split toggle";
    "$mod+Shift+t" = "layout toggle tabbed stacking split"; # TODO a mode would be more efficient
    "$mod+equal" = "exec ${import ./i3-balance-workspace.nix pkgs}/bin/i3_balance_workspace";
  };

  scratchpad = {
    "$mod+Shift+grave" = "move scratchpad";
    "$mod+grave" = "[class=.*] scratchpad show "; # toggles all scratchpad windows
  };

  media =
    let
      playerctl = args: "exec --no-startup-id ${getExe pkgs.playerctl} ${args}";
      ponymix = args: "exec --no-startup-id ${getExe pkgs.ponymix} ${args}";
    in
    {
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

  capture = optionalAttrs config.services.flameshot.enable {
    "--release Print" = ''exec --no-startup-id ${getExe config.services.flameshot.package} gui'';
  };
})
