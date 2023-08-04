{ config, lib, pkgs, ... }:

with lib;

# home-manager's eww module forces configuration be in-store and doesn't have service,
# hence we write our own.
let
  programCfg = config.my.programs.eww; # part of home-manager
  serviceCfg = config.my.services.eww; # "overlayed" options
in
{
  imports = [
    # (mkRenamedOptionsModule [ "programs" "eww" "configDir" ] [ "programs" "eww" "configPath" ])
  ];

  options.my = {
    programs.eww = {
      enable = mkEnableOption "ElKowars wacky widgets";
      package = mkPackageOption pkgs "eww" { };
      # configPath = mkOption {
      #   type = types.nullOr types.path;
      #   default = mkIf config.xdg.enable "${config.xdg.configHome}/eww";
      # };
    };
    services.eww = {
      enable = mkEnableOption "ElKowars wacky widgets daemon";
      package = mkOption {
        type = types.package;
        default = config.programs.eww.package;
      };
    };
  };

  config = {
    home.packages = optional programCfg.enable programCfg.package;
    systemd.user.services.eww = mkIf serviceCfg.enable {
      assertions = [ (lib.hm.assertions.assertPlatform "services.eww" pkgs lib.platforms.linux) ];
      Unit = {
        Description = "eww daemon";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Environment =
          let
            path = lib.makeBinPath [
              "${programCfg.package}"
              "${config.home.homeDirectory}/.nix-profile"
              "/run/wrappers/bin"
            ];
          in
          lib.mkForce "PATH=${path}";
        ExecStart = "${serviceCfg.package}/bin/eww daemon --no-daemonize";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
