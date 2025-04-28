{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  json = pkgs.formats.json { };
  cfg = config.programs.claude;
  mcpServerType = type.submodule {
    options = {
      command = mkOption {
        type = types.coercedTo types.path toString types.str;
      };
      args = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      env = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
    };
  };
in
{
  options = {
    programs.claude = {
      enable = mkEnableOption "claude";
      code = {
        enable = mkEnableOption "Claude Code" // {
          default = true;
        };
      };
      developer = {
        settings = mkOption {
          type = types.submodule {
            freeformType = json.type;
            config = {
              allowDevTools = mkEnableOption "Allow dev tools";
            };
          };
          default = { };
        };
      };
      desktop = {
        enable = mkEnableOption "Claude Desktop";
        settings = mkOption {
          type = types.submodule (
            { ... }:
            {
              freeformType = json.type;
              options = {
                mcpServers = mkOption {
                  type = types.listOf mcpServerType;
                };
              };
              config = { };
            }
          );
          default = { };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional cfg.code.enable pkgs.claude-code;
    home.file =
      optionalAttrs (cfg.developer.settings != { }) {
        "Library/Application Support/Claude/developer_settings.json".source =
          json.generate "developer_settings.json" cfg.developer.settings;
      }
      // (optionalAttrs cfg.desktop.enable && (cfg.desktop.settings != { })) {
        "Library/Application Support/Claude/claude_desktop_settings.json".source =
          json.generate "developer_settings.json" cfg.desktop.settings;
      };
  };
}
