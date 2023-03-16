{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    types
    literalExpression
    makeBinPath
    ;

  cfg = config.modules.programs.eww;

in
{
  options.modules.programs.eww = {
    enable = mkEnableOption "ElKowars wacky widgets";
  };

  config = mkIf cfg.enable {

    programs.eww = {
      enable = true;
      configDir = ../../../../config/eww;
    };

    # home.activation.ewwConfigDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   ln -s "$(${flakeRootBin})/config/eww" "${config.xdg.configHome}/eww"
    # '';

    systemd.user.services.eww = mkIf config.programs.eww.enable {
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

        ExecStart = "${config.programs.eww.package}/bin/eww daemon --no-daemonize";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
