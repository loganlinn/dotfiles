{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.my.desktop.wayland;

in
{

  options.my.desktop.wayland = {
    enable = mkEnableOption "Wayland";
  };

  config = mkIf cfg.enable {

    security.polkit.enable = true;

    systemd.user.sessionVariables = {
      "_JAVA_AWT_WM_NONREPARENTING" = 1;
      "NIXOS_OZONE_WL" = 1;
      "AWT_TOOLKIT" = "MToolkit";
      "MOZ_ENABLE_WAYLAND" = 1;
      # https://mastransky.wordpress.com/2020/03/16/wayland-x11-how-to-run-firefox-in-mixed-environment/
      # "MOZ_DBUS_REMOTE" = 1;
      "SAL_USE_VCLPLUGIN" = "gtk3";
      "QT_WAYLAND_FORCE_DPI" = "physical";

      "XCURSOR_SIZE" = 24;
      "XDG_SESSION_TYPE" = "wayland";
    };

    programs.mpv.config = {
      gpu-context = "wayland";
    };

    programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.wlrobs ];

    home.packages = with pkgs; [
      # gtk-layer-shell
    ];


  };
}
