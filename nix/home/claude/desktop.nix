{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.claude.desktop;
  json = pkgs.formats.json { };
  mkOpt = type: default: mkOption { inherit type default; };
in
{
  options = {
    programs.claude.desktop = {
      enable = mkEnableOption "Claude Desktop" // {
        default = true;
      };
      settings = mkOpt (types.submodule {
        options = {
          mcpServers = mkOpt (types.attrsOf (
            types.submodule {
              options = {
                command = mkOption {
                  type = types.coercedTo types.path toString types.str;
                };
                args = mkOpt (types.listOf types.str) [ ];
                env = mkOpt (types.attrsOf types.str) { };
              };
            }
          )) { };
        };
        freeformType = json.type;
      }) { };
      mcpServers = {
        mcp-obsidian = {
          enable = mkEnableOption "mcp-obsidian";
          env = mkOpt (types.attrsOf types.str) { };
          package = mkOpt types.package (
            pkgs.fetchFromGitHub {
              owner = "MarkusPfundstein";
              repo = "mcp-obsidian";
              rev = "0133bdd91fad5718a5377e3c3c6eaf1527f2644f";
              hash = "sha256-HcVO7zPGECjR9BgOcthXwUuj4rATBDy5jVv+nZZWz1M=";
            }
          );
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "Only macOS supported";
      }
    ];

    programs.claude.desktop.settings.mcpServers = optionalAttrs cfg.mcpServers.mcp-obsidian.enable {
      mcp-obsidian = {
        command = "${pkgs.uv}/bin/uv";
        args = [
          "--directory"
          cfg.mcpServers.mcp-obsidian.package.outPath
          "run"
          "mcp-obsidian"
        ];
        env = cfg.mcpServers.mcp-obsidian.env;
      };
    };

    home.file = optionalAttrs (cfg.settings != { }) {
      "Library/Application Support/Claude/claude_desktop_config.json".source =
        json.generate "developer_settings.json" cfg.settings;
    };
  };
}
