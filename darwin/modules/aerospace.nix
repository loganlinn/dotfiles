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

  exec-ephemeral = cmd: ''
    exec-and-forget kitty sh -c ${lib.escapeShellArg cmd}"; read -p 'Press any key to close'"
  '';


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

      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [];
      };

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

          # All possible keys:
          # - Letters.        a, b, c, ..., z
          # - Numbers.        0, 1, 2, ..., 9
          # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
          # - F-keys.         f1, f2, ..., f20
          # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
          #                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
          # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
          #                   keypadMinus, keypadMultiply, keypadPlus
          # - Arrows.         left, down, up, right

          # All possible modifiers: cmd, alt, ctrl, shift

          # All possible commands: https://nikitabobko.github.io/AeroSpace/commands
          mode.main.binding = {
            alt-enter = "exec-and-forget open -a Kitty.app";
            alt-cmd-enter = "exec-and-forget open -n -a Kitty.app";
            alt-shift-enter = "exec-and-forget /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --profile-directory=Default";
            alt-shift-ctrl-enter = "exec-and-forget /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --profile-directory=Profile\ 1";
            alt-a = "exec-and-forget open -a Emacs.app";
            alt-cmd-a = "exec-and-forget open -n -a Emacs.app";
            alt-e = "exec-and-forget open -a Finder.app";

            # See: https://nikitabobko.github.io/AeroSpace/commands#layout
            alt-slash = "layout tiles horizontal vertical";
            alt-comma = "layout accordion horizontal vertical";

            # See: https://nikitabobko.github.io/AeroSpace/commands#focus
            alt-h = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-the-workspace left";
            alt-j = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-the-workspace down";
            alt-k = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-the-workspace up";
            alt-l = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-the-workspace right";

            alt-cmd-h = "focus-monitor left";
            alt-cmd-j = "focus-monitor down";
            alt-cmd-k = "focus-monitor up";
            alt-cmd-l = "focus-monitor right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move
            alt-shift-h = "move left";
            alt-shift-j = "move down";
            alt-shift-k = "move up";
            alt-shift-l = "move right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#resize
            alt-shift-minus = "resize smart -48";
            alt-shift-equal = "resize smart +48";
            alt-ctrl-shift-minus = "resize smart -256";
            alt-ctrl-shift-equal = "resize smart +256";

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
            alt-0 = "workspace 10";
            alt-leftSquareBracket = "workspace --wrap-around prev";
            alt-rightSquareBracket = "workspace --wrap-around next";
            alt-shift-leftSquareBracket =  ["move-node-to-workspace --wrap-around next" "workspace --wrap-around prev"];
            alt-shift-rightSquareBracket = ["move-node-to-workspace --wrap-around prev" "workspace --wrap-around next"];

            # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
            alt-shift-1 = ["move-node-to-workspace  1" "workspace  1"];
            alt-shift-2 = ["move-node-to-workspace  2" "workspace  2"];
            alt-shift-3 = ["move-node-to-workspace  3" "workspace  3"];
            alt-shift-4 = ["move-node-to-workspace  4" "workspace  4"];
            alt-shift-5 = ["move-node-to-workspace  5" "workspace  5"];
            alt-shift-6 = ["move-node-to-workspace  6" "workspace  6"];
            alt-shift-7 = ["move-node-to-workspace  7" "workspace  7"];
            alt-shift-8 = ["move-node-to-workspace  8" "workspace  8"];
            alt-shift-9 = ["move-node-to-workspace  9" "workspace  9"];
            alt-shift-0 = ["move-node-to-workspace 10" "workspace 10"];

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
            alt-tab = "workspace-back-and-forth";
            # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
            alt-shift-tab = "move-workspace-to-monitor --wrap-around next";


            alt-shift-f = "layout floating tiling";
            alt-ctrl-f = "fullscreen";
            alt-ctrl-shift-f = "macos-native-fullscreen";

            alt-shift-c = "reload-config";
            alt-shift-x = "enable toggle";

            # See: https://nikitabobko.github.io/AeroSpace/commands#mode
            alt-shift-semicolon = "mode service";
            alt-shift-slash = "mode query";
          };

          mode.query.binding = {
            k = exec-ephemeral "aerospace config --all-keys";
            m = exec-ephemeral "aerospace config --major-keys";
            a = exec-ephemeral "aerospace list-apps";
            e = exec-ephemeral "aerospace list-exec-env-vars";
            d = exec-ephemeral "aerospace list-monitors";
            w = exec-ephemeral "aerospace list-windows";
            s = exec-ephemeral "aerospace list-workspaces";
            q = "mode main";
            esc = "mode main";
          };

          # 'service' binding mode declaration.
          # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
          mode.service.binding = {
            q = "mode main";
            esc = "mode main";
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

      home.packages = cfg.extraPackages;
    };

    # Move windows by holding ctrl+cmd and dragging any part of the window
    system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = lib.mkDefault true;

    # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
    system.defaults.dock.expose-group-by-app = lib.mkDefault true; # `true` means OFF

    # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
    system.defaults.spaces.spans-displays = lib.mkDefault true; # `true` means OFF

  };
}
