{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.sketchybar;
in {
  options = {
    programs.sketchybar = {
      enable = mkEnableOption "sketchybar";
    };
  };

  config = mkIf cfg.enable {
    homebrew = {
      taps = ["FelixKratz/formulae"];
      brews = ["FelixKratz/formulae/sketchybar"];
    };

    # sketchybar's default font
    fonts.packages = with pkgs; [
      hack-font
    ];
  };
}
