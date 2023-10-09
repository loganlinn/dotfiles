{ config, lib, pkgs, ... }:

with lib;

let cfg = config.my.vivaldi; in
{

  options.my.vivaldi = {
    enable = mkEnableOption "Vivaldi browser";

    enableFFmpegCodecs = (mkEnableOption "Additional support for (free + proprietary) codecs for Vivaldi") // { default = true; };

    enableWidevine = mkEnableOption "Additional support for Wildvine CDM (for EME/DRM) for Vivaldi";

    commandLineArgs = mkOption {
      type = types.str;
      default = "";
    };

    package = mkPackageOptionMD pkgs "vivaldi" { };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      default = cfg.package.override {
        commandLineArgs = cfg.commandLineArgs;
        proprietaryCodecs = cfg.enableFFmpegCodecs;
        enableWidevine = cfg.enableWidevine;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.finalPackage
    ];
  };
}
