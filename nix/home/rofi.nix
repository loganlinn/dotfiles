{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.targetPlatform.isLinux {
  programs.rofi = {
    enable = true;
    pass.enable = true;
    terminal = lib.getExe config.programs.kitty.package;
    font = "Victor Mono Regular";
    plugins = with pkgs; [
      rofi-file-browser
      rofi-calc
    ];
  };
  home.packages = with pkgs; [rofi-power-menu];
}
