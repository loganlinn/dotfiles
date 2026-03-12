{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.clickhouse;
in
  with lib; {
    options = {
      services.clickhouse = {
        enable = mkEnableOption "ClickHouse database server";

        package = mkPackageOption pkgs "clickhouse" {};

        # logLinePrefix = mkOption {
        #   type = types.str;
        #   default = "[%p] ";
        #   example = "%m [%p] ";
        #   description = ''
        #     A printf-style string that is output at the beginning of each log line.
        #     Upstream default is `'%m [%p] '`, i.e. it includes the timestamp. We do
        #     not include the timestamp, because journal has it anyway.
        #   '';
        # };
      };
    };

    config = mkIf cfg.enable {
      users.users.clickhouse = {
        name = "clickhouse";
        uid = config.ids.uids.clickhouse;
        group = "clickhouse";
        description = "ClickHouse server user";
      };

      users.groups.clickhouse.gid = config.ids.gids.clickhouse;

      # systemd.services.clickhouse = {
      #   description = "ClickHouse server";
      #
      #   wantedBy = [ "multi-user.target" ];
      #
      #   after = [ "network.target" ];
      #
      #   serviceConfig = {
      #     Type = "notify";
      #     User = "clickhouse";
      #     Group = "clickhouse";
      #     ConfigurationDirectory = "clickhouse-server";
      #     AmbientCapabilities = "CAP_SYS_NICE";
      #     StateDirectory = "clickhouse";
      #     LogsDirectory = "clickhouse";
      #     ExecStart = "${cfg.package}/bin/clickhouse-server --config-file=/etc/clickhouse-server/config.xml";
      #     TimeoutStartSec = "infinity";
      #   };
      #
      #   environment = {
      #     # Switching off watchdog is very important for sd_notify to work correctly.
      #     CLICKHOUSE_WATCHDOG_ENABLE = "0";
      #   };
      # };

      environment.etc = {
        "clickhouse-server/config.xml" = {
          source = "${cfg.package}/etc/clickhouse-server/config.xml";
        };

        "clickhouse-server/users.xml" = {
          source = "${cfg.package}/etc/clickhouse-server/users.xml";
        };
      };

      environment.systemPackages = [cfg.package];

      environment.pathsToLink = [
        "/share/clickhouse"
      ];

      launchd.user.agents.clickhouse = {
        path = [cfg.package];
        script = ''
          exec ${cfg.package}/bin/clickhouse-server
        '';
        # environment = {};
        # path = [];
        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
        serviceConfig.HardResourceLimits.NumberOfFiles = 262144;
        serviceConfig.SoftResourceLimits.NumberOfFiles = 262144;
        serviceConfig.UserName = "clickhouse";
        serviceConfig.GroupName = "clickhouse";
      };

      # startup requires a `/etc/localtime` which only if exists if `time.timeZone != null`
      time.timeZone = mkDefault "UTC";
    };
  }
