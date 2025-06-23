{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.sketchybar;
in
{
  options = {
    programs.sketchybar = {
      enable = mkEnableOption "sketchybar";
    };
    services.sketchybar = {
      enable = mkEnableOption "sketchybar";
    };
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [ "FelixKratz/formulae" ];
      brews = [
        (
          {
            name = "FelixKratz/formulae/sketchybar";
          }
          // optionalAttrs config.services.sketchybar.enable {
            start_service = true;
            restart_service = true;
          }
        )
      ];
      casks = [
        "sf-symbols"
      ];
    };

    # sketchybar's default font
    fonts.packages = with pkgs; [
      hack-font
    ];
  };
}
