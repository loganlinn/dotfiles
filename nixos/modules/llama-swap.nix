{
  self',
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.llama-swap;
  yaml = pkgs.formats.yaml {};
  configFile =
    if cfg.configFile != null
    then cfg.configFile
    else yaml.generate "llama-swap-config.yaml" cfg.settings;
in {
  options.services.llama-swap = {
    enable = lib.mkEnableOption "llama-swap model proxy";

    package = lib.mkOption {
      type = lib.types.package;
      default = self'.packages.llama-swap;
      description = "llama-swap package to use.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the llama-swap API and UI.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address to listen on.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the firewall for llama-swap.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to config.yaml. Mutually exclusive with settings.";
    };

    settings = lib.mkOption {
      type = yaml.type;
      default = {};
      description = "Configuration attrset, rendered to YAML. Ignored if configFile is set.";
    };

    watchConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Watch config file for changes and hot-reload.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    systemd.services.llama-swap = {
      description = "llama-swap model proxy";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.concatStringsSep " " (
          [
            "${cfg.package}/bin/llama-swap"
            "--config ${configFile}"
            "--listen ${cfg.listenAddress}:${toString cfg.port}"
          ]
          ++ lib.optional cfg.watchConfig "--watch-config"
        );
        Restart = "always";
        RestartSec = 10;
        # GPU access for child llama-server processes
        PrivateDevices = false;
        Environment = [
          "PATH=/run/current-system/sw/bin"
          "LD_LIBRARY_PATH=/run/opengl-driver/lib"
        ];
      };
    };
  };
}
