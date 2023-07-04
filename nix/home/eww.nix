{ config, lib, pkgs, ... }:

with lib; let
  serviceCfg = config.services.eww;
in
{
  options.services.eww = {
    enable = mkEnableOption "ElKowars wacky widgets daemon";
    package = mkOption {
      type = types.package;
      default = config.programs.eww.finalPackage or config.programs.eww.package;
    };
  };

  config = {
    programs.eww.configDir = ../../config/eww;

    # home.activation.ewwConfigDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   ln -s "$(${flakeRootBin})/config/eww" "${config.xdg.configHome}/eww"
    # '';

    systemd.user.services.eww = mkIf serviceCfg.enable {
      Unit = {
        Description = "Eww Daemon";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Environment =
          let path = lib.makeBinPath [
            "/run/wrappers"
            "${config.home.homeDirectory}/.nix-profile"
            "/etc/profiles/per-user/${config.home.username}"
            "/nix/var/nix/profiles/default"
            "/run/current-system/sw"
          ];
          in lib.mkForce "PATH=${path}";

        ExecStart = "${serviceCfg.package}/bin/eww daemon --no-daemonize";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
