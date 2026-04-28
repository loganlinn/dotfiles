{
  config,
  lib,
  pkgs,
  inputs',
  osConfig ? {},
  ...
}:
let
  cfg = config.wayland.windowManager.hyprland;

  hasNvidia =
    let
      drivers = osConfig.services.xserver.videoDrivers or [];
    in
    builtins.elem "nvidia" drivers;
in
{
  imports = [
    ./settings.nix
    ./bindings.nix
    ./looknfeel.nix
    ./input.nix
    ./windows.nix
    ./autostart.nix
    ./screenshots.nix
  ];

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      package = lib.mkDefault inputs'.hyprland.packages.hyprland;
      portalPackage = lib.mkDefault null; # NixOS module handles the portal
      systemd.enable = lib.mkDefault true;
      xwayland.enable = lib.mkDefault true;
    };

    home.packages = with pkgs; [
      brightnessctl # display/keyboard brightness (bound in keybindings + hypridle)
      playerctl # media player control (bound in keybindings)
    ];

    home.sessionVariables =
      {
        NIXOS_OZONE_WL = "1";
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        GDK_BACKEND = "wayland,x11,*";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        MOZ_ENABLE_WAYLAND = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      }
      // lib.optionalAttrs hasNvidia {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        # LIBVA_DRIVER_NAME omitted — nvidia.nix notes it breaks OBS
        NVD_BACKEND = "direct";
      };
  };
}
