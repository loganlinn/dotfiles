{
  pkgs,
  lib,
  ...
}:
with lib;
with types;
let
  mkOpt = type: default: mkOption { inherit type default; };
  exeType = (coercedTo package getExe str);
in
{
  options.my.hyprland = {
    terminal = mkOpt exeType pkgs.kitty;
    browser = mkOpt exeType pkgs.firefox;
    editor = mkOpt exeType "${pkgs.kitty}/bin/kitty sh -c 'exec $${EDITOR-vim}'";
    fileManager = mkOpt exeType "${pkgs.kitty}/bin/kitty --class=yazi ${pkgs.yazi}/bin/yazi";
  };
}
