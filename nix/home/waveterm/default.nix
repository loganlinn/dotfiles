{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  json = pkgs.formats.json { };
  cfg = config.programs.waveterm;
in
{
  options.programs.waveterm = {
    enable = mkEnableOption "waveterm";
    settings = mkOption {
      type = types.submodule {
        freeformType = json.type;
        config = {

        };
      };
      default = {
        "telemetry:enabled" = false;
      };
    };
  };

  config = {
    home.packages = [ pkgs.waveterm ];
    xdg.configFile."waveterm/settings.json".source = json.generate "settings.json" cfg.settings;
  };
}
