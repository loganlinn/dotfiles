{ config, lib, pkgs, ... }:

with lib;

let
  programCfg = config.programs.btrbk;
  serviceCfg = config.services.btrbk;
in {

  options = {
    services.btrbk = {
      enable = mkEnableOption "btrbk service"

      frequency = mkOption {
        type = types.str;
        default = "hourly";
        description = ''
          How often to run btrbk when
          <code language="nix">services.btrbk.enable = true</code>.
          This value is passed to the systemd timer configuration as
          the onCalendar option. See
          <citerefentry>
            <refentrytitle>systemd.time</refentrytitle>
            <manvolnum>7</manvolnum>
          </citerefentry>
          for more information about the format.
        '';
      };

      configFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
             Configuration file for btrbk service.
         '';
      };
    }

  };

  config = mkIf  serviceConfig.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.btrbk" pkgs
        lib.platforms.linux)
    ];

    systemd.user = {
      services.btrbk = {
        Unit = {
          Description = "btrbk backup";
          Documentation = "man:btrbk(1)";
          # Prevent btrbk from running unless the machine is
          # plugged into power:
          ConditionACPower = true;
        };
        Service = {
          Type = "oneshot";

          # Lower CPU and I/O priority:
          Nice = 19;
          CPUSchedulingPolicy = "batch";
          IOSchedulingClass = "best-effort";
          IOSchedulingPriority = 7;
          IOWeight = 100;

          Restart = "no";
          LogRateLimitIntervalSec = 0;

          # Delay start to prevent backups running during boot:
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 3m";

          ExecStart = ''
            ${pkgs.systemd}/bin/systemd-inhibit \
              --who="btrbk" \
              --why="Prevent interrupting scheduled backup" \
              ${programConfig.package}/bin/btrbk ${if cfg.configFile != null then "-c ${cfg.configFile} " else ""}run
          '';
        };
      };

      timers.btrbk = {
        Unit.Description = "Run btrbk backup";
        Timer = {
          OnCalendar = serviceConfig.frequency;
          Persistent = true;
          RandomizedDelaySec = "10m";
          AccuracySec = "10m";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };

    # environment.systemPackages = [ pkgs.btrbk ];
    # environment.etc."btrbk/btrbk.conf".text = ''
    #   timestamp_format        long
    #   snapshot_preserve_min   6h
    #   snapshot_preserve       48h 20d 6m
    #   volume /.subvols
    #     snapshot_dir btrbk_snapshots
    #     subvolume @home
    #     snapshot_create onchange
    # '';
  };

}
