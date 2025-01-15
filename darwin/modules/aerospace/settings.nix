{
  config,
  pkgs,
  lib,
}:

with lib;

let
  cfg = config.programs.aerospace;
  app-ids = import ./app-ids.nix;

  # mkOpt =
  #   type: default: arg:
  #   mkOption { inherit type default; } // (if isString arg then { description = arg; } else arg);
  # layout-type = types.enum [
  #   "h_tiles"
  #   "v_tiles"
  #   "h_accordion"
  #   "v_accordion"
  # ];
  # keyseq-type = types.strMatching "([a-zA-Z0-9]+)(-([a-zA-Z0-9]+))*";
  # workspace-type =
  #   with types;
  #   submodule (
  #     { name, config, ... }:
  #     {
  #       options = {
  #         name = mkOpt str name { };
  #         layout = mkOpt (nullOr layout-type) null { };
  #         binding = mkOpt (attrsOf keyseq-type) {} { };
  #         on.workspace-change.exec = mkOpt (nullOr (nonEmptyListOf nonEmptyStr)) null { };
  #         on.window-detected.run = mkOpt (listOf nonEmptyStr) [ ] { };
  #       };
  #     }
  #   );
  # workspaces = {
  #   "0:misc" = { };
  #   "1:editor" = { };
  #   "2:term" = { };
  #   "3:www" = { };
  #   "4:" = { };
  #   "5" = { };
  #   "6" = { };
  #   "7" = { };
  #   "9" = { };
  # };

  focus-or-launch-app-id = pkgs.writeShellScript "focus-or-launch-app" ''
    set -e
    set -o pipefail

    app_bundle_id=''${1:?app-bundle-id}

    window_id=$(
      ${config.homebrew.brewPrefix}/aerospace list-windows \
        --app-bundle-id "$app_bundle_id" \
        --monitor all \
        --format '%{window-id}' |
      head -n1 ||
      true
    )

    if [[ -n $window_id ]]; then
      echo >&2 "Focusing window: $window_id"
      ${config.homebrew.brewPrefix}/aerospace focus --window-id "$window_id"
    else
      echo >&2 "Launching app: $app_bundle_id"
      /usr/bin/open -b "$app_bundle_id"
    fi
  '';

  # All possible modifiers: cmd, alt, ctrl, shift
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
  #
  # Note: [pageUp/pageDown are not supported](https://github.com/nikitabobko/AeroSpace/issues/748).
  #
  # All possible commands: https://nikitabobko.github.io/AeroSpace/commands
  mode = {
    main.binding = {
      alt-enter = "exec-and-forget ${focus-or-launch-app-id} ${cfg.terminal.id}";
      alt-shift-enter = "exec-and-forget /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --profile-directory=Default";
      alt-shift-ctrl-enter = "exec-and-forget Firefox";
      alt-a = "exec-and-forget ${cfg.editor.exec}";
      alt-period = "exec-and-forget open -b ${app-ids.Finder}";

      # See: https://nikitabobko.github.io/AeroSpace/commands#layout
      alt-slash = "layout tiles horizontal vertical";
      alt-comma = "layout accordion horizontal vertical";

      # See: https://nikitabobko.github.io/AeroSpace/commands#focus
      alt-h = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-the-workspace left";
      alt-j = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-the-workspace down";
      alt-k = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-the-workspace up";
      alt-l = "focus --boundaries all-monitors-outer-frame --boundaries-action wrap-around-the-workspace right";

      alt-cmd-h = "move-node-to-monitor --wrap-around --focus-follows-window left";
      alt-cmd-j = "move-node-to-monitor --wrap-around --focus-follows-window down";
      alt-cmd-k = "move-node-to-monitor --wrap-around --focus-follows-window up";
      alt-cmd-l = "move-node-to-monitor --wrap-around --focus-follows-window right";

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
      alt-shift-left = "resize width -48";
      alt-shift-down = "resize height +48";
      alt-shift-up = "resize height -48";
      alt-shift-right = "resize width +48";

      alt-leftSquareBracket = "workspace --wrap-around prev";
      alt-rightSquareBracket = "workspace --wrap-around next";
      alt-shift-leftSquareBracket = "move-node-to-workspace --focus-follows-window --wrap-around next";
      alt-shift-rightSquareBracket = "move-node-to-workspace --focus-follows-window --wrap-around prev";

      # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
      alt-backtick = "workspace 0";
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
      alt-s = "workspace s";
      alt-m = "workspace m";
      alt-p = "workspace p";

      # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
      alt-shift-1 = "move-node-to-workspace --focus-follows-window  1";
      alt-shift-2 = "move-node-to-workspace --focus-follows-window  2";
      alt-shift-3 = "move-node-to-workspace --focus-follows-window  3";
      alt-shift-4 = "move-node-to-workspace --focus-follows-window  4";
      alt-shift-5 = "move-node-to-workspace --focus-follows-window  5";
      alt-shift-6 = "move-node-to-workspace --focus-follows-window  6";
      alt-shift-7 = "move-node-to-workspace --focus-follows-window  7";
      alt-shift-8 = "move-node-to-workspace --focus-follows-window  8";
      alt-shift-9 = "move-node-to-workspace --focus-follows-window  9";
      alt-shift-0 = "move-node-to-workspace --focus-follows-window 10";
      alt-shift-s = "move-node-to-workspace --focus-follows-window s";
      alt-shift-m = "move-node-to-workspace --focus-follows-window m";
      alt-shift-p = "move-node-to-workspace --focus-follows-window p";

      # https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
      # alt-ctrl-shift-pageDown = "move-workspace-to-monitor --wrap-around next";
      # alt-ctrl-shift-pageUp = "move-workspace-to-monitor --wrap-around prev";

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
      # alt-shift-m = "mode monitor";
      alt-shift-semicolon = "mode service";
      # alt-shift-slash = "mode query";
    };

    # https://nikitabobko.github.io/AeroSpace/commands#move-node-to-monitor
    # https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
    monitor.binding = prefix-mode-binding // {
      h = [
        "move-node-to-monitor --wrap-around --focus-follows-window right"
        "mode main"
      ];
      j = [
        "move-node-to-monitor --wrap-around --focus-follows-window down"
        "mode main"
      ];
      k = [
        "move-node-to-monitor --wrap-around --focus-follows-window up"
        "mode main"
      ];
      l = [
        "move-node-to-monitor --wrap-around --focus-follows-window left"
        "mode main"
      ];
      n = [
        "move-workspace-to-monitor --wrap-around next"
        "mode main"
      ];
      p = [
        "move-workspace-to-monitor --wrap-around prev"
        "mode main"
      ];
    };

    # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
    service.binding = prefix-mode-binding // {
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

  prefix-mode-binding = {
    q = "mode main";
    esc = "mode main";
    ctrl-c = "mode main";
  };

  # utils
  aerospace-summon-app = pkgs.writeShellScriptBin "aerospace-summon-app" (
    builtin.readFile ./bin/aerospace-summon-app.sh
  );
in
{
  after-startup-command = optional cfg.borders.enable "exec-and-forget ${config.homebrew.brewPrefix}/borders ${
    # https://github.com/FelixKratz/JankyBorders/wiki/Man-Page#options
    cli.toGNUCommandLineShell {
      mkBool = key: val: [ "--${key}=${if v then "on" else "off"}" ];
      mkList = key: vals: [ "--${key}=${concatStringsSep "," vals}" ];
    } cfg.borders.settings
  }";

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

  # https://nikitabobko.github.io/AeroSpace/guide#on-window-detected-callback
  # TODO process cfg.apps.*.layout
  #
  # Obtaining app-id:
  #     aerospace list-apps --json | jq '.[].["app-bundle-id"]'
  #     mdls -name kMDItemCFBundleIdentifier -r Example.app
  #
  on-window-detected = concatLists [
    ## initial workspace assignment
    # by app-id
    (mapAttrsToList
      (app-id: workspace: {
        "if" = {
          inherit app-id;
        };
        run = "move-node-to-workspace ${toString workspace}";
      })
      {
        "org.gnu.Emacs" = 1;
        # "com.github.wez.WezTerm" = 1;
        "com.linear" = 4;
        "${app-ids."Google Chrome"}" = 3;
        "${app-ids.Slack}" = "s";
        "${app-ids.Messages}" = "m";
      }
    )
    # by app-name
    (mapAttrsToList
      (app-name-regex-substring: workspace: {
        "if" = {
          inherit app-name-regex-substring;
        };
        run = "move-node-to-workspace ${toString workspace}";
      })
      {
        # "WezTerm" = 2;
        "Excalidraw" = 4;
        "SoundCloud" = 9;
      }
    )

    ## floating layout
    (forEach
      [
        "1Password"
        "Activity Monitor"
        "App Store"
        "Calculator"
        "Clock"
        "Console"
        "Contacts"
        "Dictionary"
        "FaceTime"
        "Finder"
        "Keychain Access"
        "Messages"
        "Notes"
        "Preview"
        "Reminders"
        "Zoom"
        "System Settings"
        {
          window-title-regex-substring = "Hammerspoon";
        }
        {
          window-title-regex-substring = "wezterm Configuration Error";
        }
      ]
      (app: {
        "if" =
          if isString app then
            { app-id = app-ids.${app}; }
          else
            assert isAttrs app;
            app;
        run = "layout floating";
      })
    )
  ];

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

  mode = mode;
}
