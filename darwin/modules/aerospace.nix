{
  self,
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.aerospace;

  toml = pkgs.formats.toml { };

  configFile = toml.generate "aerospace.toml" cfg.settings;
in
{
  imports = [
    ./sketchybar.nix
    {
      # a.k.a JankyBorders
      homebrew.taps = [ "FelixKratz/formulae" ];
      homebrew.brews = [ "FelixKratz/formulae/borders" ];
    }
  ];

  options = {
    programs.aerospace = {
      enable = mkEnableOption "aerospace window manager";
      settings = mkOption {
        type = types.submodule {
          freeformType = toml.type;
        };

        default = {
          after-startup-command = [
            # use gh:FelixKratz/JankyBorders to higlight focus
            "exec-and-forget ${config.homebrew.brewPrefix}/borders"
          ];

          # Start AeroSpace at login
          start-at-login = true;

          # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;

          # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
          # The 'accordion-padding' specifies the size of accordion padding
          # You can set 0 to disable the padding feature
          accordion-padding = 30;

          # Possible values: tiles|accordion
          default-root-container-layout = "tiles";

          # Possible values: horizontal|vertical|auto
          # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
          #               tall monitor (anything higher than wide) gets vertical orientation
          default-root-container-orientation = "auto";

          # Possible values: (qwerty|dvorak)
          # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
          key-mapping.preset = "qwerty";

          # Mouse follows focus when focused monitor changes
          # Drop it from your config, if you don't like this behavior
          # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
          # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
          # Fallback value (if you omit the key): on-focused-monitor-changed = []
          on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

          # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
          # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
          # Also see: https://nikitabobko.github.io/AeroSpace/goodness#disable-hide-app
          # automatically-unhide-macos-hidden-apps = true

          gaps = {
            inner.horizontal = 0;
            inner.vertical = 0;
            outer.left = 0;
            outer.bottom = 0;
            outer.top = 0;
            outer.right = 0;
          };

          exec = {
            inherit-env-vars = true;
          };

          mode.main.binding = {
            alt-enter = "exec-and-forget open -a kitty.app";
            alt-cmd-enter = "exec-and-forget open -n -a kitty.app";
            alt-shift-enter = "exec-and-forget /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --profile-directory=Default";
            alt-shift-ctrl-enter = "exec-and-forget /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --profile-directory=Profile\ 1";
            alt-e = "exec-and-forget open -a emacs.app";
            alt-cmd-e = "exec-and-forget open -n -a emacs.app";

            # See: https://nikitabobko.github.io/AeroSpace/commands#layout
            alt-slash = "layout tiles horizontal vertical";
            alt-comma = "layout accordion horizontal vertical";

            # See: https://nikitabobko.github.io/AeroSpace/commands#focus
            alt-h = "focus left";
            alt-j = "focus down";
            alt-k = "focus up";
            alt-l = "focus right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move
            alt-shift-h = "move left";
            alt-shift-j = "move down";
            alt-shift-k = "move up";
            alt-shift-l = "move right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#resize
            alt-shift-minus = "resize smart -50";
            alt-shift-equal = "resize smart +50";

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
            alt-1 = "workspace 1";
            alt-2 = "workspace 2";
            alt-3 = "workspace 3";
            alt-4 = "workspace 4";
            alt-5 = "workspace 5";
            alt-6 = "workspace 6";
            alt-7 = "workspace 7";
            alt-8 = "workspace 8";
            alt-9 = "workspace 9";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
            alt-shift-1 = "move-node-to-workspace 1";
            alt-shift-2 = "move-node-to-workspace 2";
            alt-shift-3 = "move-node-to-workspace 3";
            alt-shift-4 = "move-node-to-workspace 4";
            alt-shift-5 = "move-node-to-workspace 5";
            alt-shift-6 = "move-node-to-workspace 6";
            alt-shift-7 = "move-node-to-workspace 7";
            alt-shift-8 = "move-node-to-workspace 8";
            alt-shift-9 = "move-node-to-workspace 9";
            # alt-shift-a = "move-node-to-workspace A";
            # alt-shift-b = "move-node-to-workspace B";
            # alt-shift-c = "move-node-to-workspace C";
            # alt-shift-d = "move-node-to-workspace D";
            # alt-shift-e = "move-node-to-workspace E";
            # alt-shift-f = "move-node-to-workspace F";
            # alt-shift-g = "move-node-to-workspace G";
            # alt-shift-i = "move-node-to-workspace I";
            # alt-shift-m = "move-node-to-workspace M";
            # alt-shift-n = "move-node-to-workspace N";
            # alt-shift-o = "move-node-to-workspace O";
            # alt-shift-p = "move-node-to-workspace P";
            # alt-shift-q = "move-node-to-workspace Q";
            # alt-shift-r = "move-node-to-workspace R";
            # alt-shift-s = "move-node-to-workspace S";
            # alt-shift-t = "move-node-to-workspace T";
            # alt-shift-u = "move-node-to-workspace U";
            # alt-shift-v = "move-node-to-workspace V";
            # alt-shift-w = "move-node-to-workspace W";
            # alt-shift-x = "move-node-to-workspace X";
            # alt-shift-y = "move-node-to-workspace Y";
            # alt-shift-z = "move-node-to-workspace Z";

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
            alt-tab = "workspace-back-and-forth";
            # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
            alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

            # See: https://nikitabobko.github.io/AeroSpace/commands#mode
            alt-shift-semicolon = "mode service";
          };

          # 'service' binding mode declaration.
          # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
          mode.service.binding = {
            esc = [
              "reload-config"
              "mode main"
            ];
            r = [
              "flatten-workspace-tree"
              "mode main"
            ]; # reset layout
            f = [
              "layout floating tiling"
              "mode main"
            ]; # Toggle between floating and tiling layout
            backspace = [
              "close-all-windows-but-current"
              "mode main"
            ];
            # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
            #s = ['layout sticky tiling' 'mode main']
            alt-shift-h = [
              "join-with left"
              "mode main"
            ];
            alt-shift-j = [
              "join-with down"
              "mode main"
            ];
            alt-shift-k = [
              "join-with up"
              "mode main"
            ];
            alt-shift-l = [
              "join-with right"
              "mode main"
            ];

          };
        };
      };
    };
  };

  config = {
    homebrew = {
      taps = [ "nikitabobko/tap" ];
      casks = [ "nikitabobko/tap/aerospace" ];
    };

    home-manager.users.${config.my.user.name} = {
      xdg.configFile."aerospace/aerospace.toml".source = configFile;
    };

    # Move windows by holding ctrl+cmd and dragging any part of the window
    system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = lib.mkDefault true;

    # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
    system.defaults.dock.expose-group-by-app = lib.mkDefault true; # `true` means OFF

    # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
    system.defaults.spaces.spans-displays = lib.mkDefault true; # `true` means OFF

  };
}
