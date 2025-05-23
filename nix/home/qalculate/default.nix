{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  home.packages = with pkgs;
    [libqalculate]
    ++ (
      if config.gtk.enable
      then [qalculate-gtk]
      else if config.qt.enable
      then [qalculate-qt]
      else []
    );

  xdg.configFile."qalculate/qalc.cfg".source = ./qalc.cfg;
}
