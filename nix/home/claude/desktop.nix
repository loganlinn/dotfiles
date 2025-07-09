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
      enable = mkEnableOption "Claude Desktop";
      settings = mkOpt json.type { };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "Only macOS supported";
      }
    ];

    home.file = optionalAttrs (cfg.settings != { }) {
      "Library/Application Support/Claude/claude_desktop_config.json".source =
        json.generate "claude_desktop_config.json" cfg.settings;
    };
  };
}
