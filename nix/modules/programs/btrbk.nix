{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.btrbk;
in {

  options = {
    programs.btrbk = {
      enable = mkEnableOption "btrbk";
      package = mkPackageOption pkgs "btrbk" { };
      defaultConfig = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = ''
          timestamp_format        long
          snapshot_preserve_min   6h
          snapshot_preserve       48h 20d 6m
          volume /.subvols
            snapshot_dir btrbk_snapshots
            subvolume @home
            snapshot_create onchange
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.borgmatic" pkgs
        lib.platforms.linux)
    ];

    environment.systemPackages = [ cfg.package ];

    environment.etc."btrbk/btrbk.conf" = mkIf cfg.defaultConfig != null {
      text = cfg.defaultConfig;
    };
  };
}
