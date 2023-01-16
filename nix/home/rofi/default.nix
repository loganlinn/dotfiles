{ config
, lib
, pkgs
, ...
}:
with lib;
mkIf pkgs.stdenv.targetPlatform.isLinux {
  programs.rofi = {
    enable = mkDefault true;
    pass.enable = mkIf config.programs.password-store.enable true;
    font = mkDefault "DejaVu Sans Mono";
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-file-browser
      rofi-pulse-select
    ];
  };

  home.packages = with pkgs; [
    (writeShellApplication {
      name = "powermenu";
      runtimeInputs = with pkgs; [
        config.programs.rofi.finalPackage
        rofi-power-menu
      ];
      text = ''
        rofi -show p -modi p:rofi-power-menu -width 20 -lines 6
      '';
    })
  ];
}
