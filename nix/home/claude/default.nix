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
in
{
  imports = [ ./desktop.nix ];

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
          type = types.attrsOf json.type;
          default = { };
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
    home.packages = optional cfg.code.enable pkgs.claude-code;
    home.file = optionalAttrs (cfg.developer.settings != { }) {
      "Library/Application Support/Claude/developer_settings.json".source =
        json.generate "developer_settings.json" cfg.developer.settings;
    };
  };
}
