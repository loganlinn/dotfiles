{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
  mkIf pkgs.stdenv.targetPlatform.isLinux (let
    rofi = config.programs.rofi.finalPackage;
    kitty = config.programs.kitty.package;
    powermenu = pkgs.writeShellScriptBin "powermenu" ''
      ${getExe rofi} -show p -modi p:${getExe pkgs.rofi-power-menu} -width 20 -lines 6
    '';
  in {
    programs.rofi = {
      enable = true;
      pass.enable = true;
      terminal = getExe kitty;
      font = "Victor Mono Regular";
      plugins = with pkgs; [rofi-file-browser rofi-calc];
    };

    home.packages = with pkgs; [powermenu];
  })
