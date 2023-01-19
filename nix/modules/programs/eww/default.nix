{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.modules.programs.eww;

in
{
  options.modules.programs.eww = {
    enable = mkEnableOption "ElKowars wacky widgets";
  };

  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };
}
