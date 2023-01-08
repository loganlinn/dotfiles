{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.targetPlatform.isLinux {
  programs.rofi = {
    enable = true;
    pass.enable = true;
  };
}
