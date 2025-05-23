{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.asciinema;
  toml = pkgs.formats.toml { };
in
{
  options.programs.asciinema = {
    enable = mkEnableOption "asciinema";
    package = mkPackageOption pkgs "asciinema" { };
    settings = mkOption {
      description = "https://docs.asciinema.org/manual/cli/configuration/";
      type = types.attrsOf toml.type;
      default = {
        api.url = "https://asciinema.org";
        record.stdin = true;
        record.idle_time_limit = 3;
        record.pause_key = "^1";
        record.add_marker_key = "^2";
        record.prefix_key = "^a";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."asciinema/config".source = toml.generate "asciinema-config" cfg.settings;
  };
}
