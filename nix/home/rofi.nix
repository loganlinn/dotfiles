{ config, lib, pkgs, ... }:

with lib;

mkIf pkgs.stdenv.targetPlatform.isLinux {
  programs.rofi = {
    enable = true;
    pass.enable = true;
    terminal = getExe config.programs.kitty.package;
    font = "Victor Mono Regular";
    plugins = with pkgs; [ rofi-file-browser rofi-calc ];
  };
  home.packages = with pkgs; [
    rofi-power-menu
    (writeShellScriptBin "powermenu" ''
      rofi -show p -modi p:rofi-power-menu -width 20 -lines 6
    '')
  ];
}
