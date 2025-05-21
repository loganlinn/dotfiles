{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with types;
let
  mkOpt = type: default: mkOption { inherit type default; };
  exeType = (coercedTo package getExe str);
  cfg = config.my.hyprland;
in
{
  options.my.hyprland = {
    terminal = mkOpt exeType "${getExe' pkgs.xdg-utils "xdg-terminal"}";
    browser = mkOpt exeType "${getExe' pkgs.xdg-utils "xdg-open"} http://about:blank";
    editor = mkOpt exeType "${cfg.terminal} sh -c 'exec $${EDITOR-vim}'";
    fileManager = mkOpt exeType "${cfg.terminal} '${getExe pkgs.yazi}'";
    processManager = mkOpt exeType "${cfg.terminal} '${getExe pkgs.btop}'";
  };
}
