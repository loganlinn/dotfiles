{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.sunbeam;
in
{
  options = {
    programs.sunbeam = {
      enable = mkEnableOption "sunbeam";
    };
  };
  config = mkIf cfg.enable {
    homebrew.taps = [ "pomdtr/tap" ];
    homebrew.brews = [ "pomdtr/tap/sunbeam" ];
  };
}
