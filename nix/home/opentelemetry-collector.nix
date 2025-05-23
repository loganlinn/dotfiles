{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types getExe;

  cfg = config.my.opentelemetry-collector;
  opentelemetry-collector = cfg.package;

  settingsFormat = pkgs.formats.yaml {};

  configFile =
    if cfg.configFile == null
    then settingsFormat.generate "config.yaml" cfg.settings
    else cfg.configFile;
in {
  options.my.opentelemetry-collector = {
    enable = mkEnableOption (lib.mdDoc "Opentelemetry Collector");

    package = mkOption {
      type = types.package;
      default = pkgs.opentelemetry-collector;
      defaultText = lib.literalExpression "pkgs.opentelemetry-collector";
      description = lib.mdDoc "The opentelemetry-collector package to use.";
    };

    settings = mkOption {
      type = settingsFormat.type;
      default = {};
      description = lib.mdDoc ''
        Specify the configuration for Opentelemetry Collector in Nix.

        See https://opentelemetry.io/docs/collector/configuration/ for available options.
      '';
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = lib.mdDoc ''
        Specify a path to a configuration file that Opentelemetry Collector should use.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.settings == {}) != (cfg.configFile == null);
        message = ''
          Please specify a configuration for Opentelemetry Collector with either
          'services.opentelemetry-collector.settings' or
          'services.opentelemetry-collector.configFile'.
        '';
      }
    ];

    systemd.user.services.opentelemetry-collector = {
      Unit.Desecription = "Opentelemetry Collector Service Daemon";
      Install.WantedBy = ["default.target"];
      Service.ExecStart = "${getExe opentelemetry-collector} --config=file:${configFile}";
    };
  };
}
