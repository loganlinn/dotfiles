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

  xdg.configFile."rofi/colors.rasi".source = ./colors.rasi;
  xdg.configFile."rofi/launcher.rasi".source = ./launcher.rasi;
  xdg.configFile."rofi/notifications.rasi".source = ./notifications.rasi;

  home.packages = with pkgs;
    [
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
      (writeShellApplication {
        name = "launcher";
        runtimeInputs = with pkgs; [
          config.programs.rofi.finalPackage
        ];
        text = ''
          rofi -no-lazy-grab \
          -disable-history \
          -modi "drun" \
          -show drun \
          -theme ${config.xdg.configHome}/rofi/launcher.rasi
        '';
      })
    ];
}
