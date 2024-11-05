{ config, lib, ... }:
with lib;
let
  cfg = config.programs.utm;
in
{
  options.programs.utm = {
    enable = mkEnableOption "UTM Virtual Machines";
  };
  config = mkIf cfg.enable {
    homebrew.masApps.UTM = 1538878817;
  };
}
