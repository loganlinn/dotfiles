{
  config,
  pkgs,
  lib,
}:
let
  cfg = config.programs.uv;
  toml = pkgs.formats.toml { };
in
{
  options = {
    programs.uv = {
      enable = lib.mkEnableOption "uv";
      package = lib.mkPackageOption pkgs "uv" { };
      settings = lib.mkOption {
        type = toml.type;
        default = { };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile = lib.optionalAttrs (cfg.settings != { }) {
      "uv/config.toml".source = toml.generate "uv-config" cfg.settings;
    };
  };
}
