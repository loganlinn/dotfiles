{
  inputs',
  config,
  lib,
  pkgs,
  ...
}: {
  assertions = [
    {
      assertion =
        builtins.any (d: d == "nvidia") (config.services.xserver.videoDrivers or [])
        -> (config.hardware.nvidia.modesetting.enable or false);
      message = "Hyprland: NVIDIA GPU detected (xserver.videoDrivers contains 'nvidia') but hardware.nvidia.modesetting.enable is not set. Import the nvidia NixOS module for proper Wayland support.";
    }
  ];

  programs.hyprland = {
    enable = true;
    package = lib.mkDefault inputs'.hyprland.packages.hyprland;
  };

  xdg.portal = {
    enable = lib.mkDefault true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # XDG_SESSION_TYPE is set per-session by Hyprland and the HM module;
    # setting it system-wide would affect GNOME X11 sessions.
  };

  environment.systemPackages = with pkgs; [
    libnotify
    wl-clipboard
    xdg-utils
  ];
}
