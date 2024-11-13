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
    freeformType = toml.type;
  };

  app = types.submodule (
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
      type = app;
      default = {
        exec = "open -a TextEdit";
      };
    };

    terminal = mkOption {
      type = app;
      default = {
        exec = "open -a Terminal";
      };
    };

    # TODO generalize ^^
    # apps = mkOption {
    #   type = types.attrsOf appType;
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
