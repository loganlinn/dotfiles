{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
# home-manager's eww module forces configuration be in-store and doesn't have service,
# hence we write our own.
  let
    cfg = config.my.eww;
  in {
    options.my.eww = {
      enable = mkEnableOption "ElKowars wacky widgets";
      package = mkPackageOption pkgs "eww" {};
      service.enable = mkEnableOption "ElKowars wacky widgets daemon";
    };

    config = mkIf cfg.enable {
      home.packages = [cfg.package];

      systemd.user.services.eww = mkIf cfg.service.enable {
        assertions = [(lib.hm.assertions.assertPlatform "services.eww" pkgs lib.platforms.linux)];
        Unit = {
          Description = "eww daemon";
          PartOf = ["graphical-session.target"];
        };
        Service = {
          Environment = let
            path = lib.makeBinPath [
              "${cfg.package}"
              "${config.home.homeDirectory}/.nix-profile"
              "/run/wrappers/bin"
            ];
          in
            lib.mkForce "PATH=${path}";
          ExecStart = "${cfg.package}/bin/eww daemon --no-daemonize";
          Restart = "on-failure";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
  }
