{
  config,
  pkgs,
  lib,
}:

with lib;

let
  toml = pkgs.formats.toml { };

  settings = types.submodule {
    # TODO
    # after-login-command: Command|Command[]
    # after-startup-command: Command|Command[]
    # on-focus-changed: Command|Command[]
    # on-focused-monitor-changed: Command|Command[]
    # enable-normalization-flatten-containers: bool
    # enable-normalization-opposite-orientation-for-nested-containers: bool
    # default-root-container-layout: Layout
    # default-root-container-orientation: Orientation
    # start-at-login: bool
    # automatically-unhide-macos-hidden-apps: bool
    # accordion-padding: int
    # exec-on-workspace-change: Command[]
    # exec: Command[]
    # key-mapping: table<string, string>
    # mode: map<string, Mode>
    # gaps: Gaps
    # workspace-to-monitor-force-assignment: map<string, string>
    # on-window-detected
    options = {
      mode = mkOption {
        type = types.attrsOf modeModule;
        default = { };
      };
    };
    freeformType = toml.type;
  };

  modeModule =
    with lib.types;
    let
      modifierNames = [
        "cmd"
        "alt"
        "ctrl"
        "shift"
      ];
      checkHotkey =
        binding:
        let
          syms = strings.splitString "-" binding;
          mods = lists.init syms;
          key = lists.last syms;
          nonEmptyString = x: builtins.match "[ \t\n]*" x == null;
        in
        nonEmptyString key && all (x: elem x modifierNames) mods && lists.allUnique mods;
      checkBindings = bindings: all checkHotkey (attrNames bindings);
      commandType = either nonEmptyStr (nonEmptyListOf nonEmptyStr);
      bindingsType = addCheck (attrsOf commandType) checkBindings;
    in
    submodule (
      { name, config, ... }:
      {
        options = {
          binding = mkOption {
            type = bindingsType;
            default = { };
          };
        };
      }
    );

  appModule = types.submodule (
    { config, name, ... }:
    {
      options = {
        name = mkOption {
          type = types.nullOr types.str;
          default = name;
        };
        id = mkOption {
          description = "application bundle identifier";
          type = types.nullOr types.str;
          default = null;
        };
        exec = mkOption {
          type = types.str;
          default =
            if config.id != null && config.id != "" then
              "open -b ${escapeShellArg config.id}"
            else if config.name != null && config.name != "" then
              "open -a ${escapeShellArg config.name}"
            else
              throw "exec not provided";
        };
        layout = mkOption {
          type = types.nullOr layoutType;
          default = null;
        };
        workspace = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
    }
  );

  borders = types.submodule {
    options = {
      enable = mkEnableOption "JankyBorders";
      settings = mkOption {
        type = types.attrs;
        default = {
          active_color = "0xffe1e3e4";
          inactive_color = "0xff494d64";
          width = 5.0;
        };
      };
    };
  };
in
{
  programs.aerospace = {
    enable = mkEnableOption "aerospace window manager";

    editor = mkOption {
      type = appModule;
      default = {
        exec = "open -a TextEdit";
      };
    };

    terminal = mkOption {
      type = appModule;
      default = {
        exec = "open -a Terminal";
      };
    };

    # TODO generalize ^^
    # apps = mkOption {
    #   type = types.attrsOf appModule;
    #   default = {};
    # };

    borders = mkOption {
      type = borders;
      default = {
        enable = true;
      };
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };

    settings = mkOption {
      type = settings;
      default = import ./settings.nix { inherit config pkgs lib; };
    };
  };
}
