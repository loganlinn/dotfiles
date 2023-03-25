{ config, lib, pkgs, ... }:

# WIP WIP WIP
# TODO https://github.com/nix-community/nixpkgs-wayland
let
  nverStable = config.boot.kernelPackages.nvidiaPackages.stable.version;
  nverBeta = config.boot.kernelPackages.nvidiaPackages.beta.version;
  nvidiaPackage =
    if (lib.versionOlder nverBeta nverStable)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;

  extraEnv = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  cfg = config.modules.wayland;
in
{
  options.modules.wayland = with lib; {
    enable = mkEnableOption "wayland";
  };

  config = lib.mkIf cfg.enable {
    # home-manager.users.cole = { pkgs, ... }: {
    #   wayland.windowManager.sway = {
    #     extraOptions = [ "--unsupported-gpu" ];
    #   };
    # };

    environment.variables = extraEnv;
    environment.sessionVariables = extraEnv;
    environment.systemPackages = with pkgs; [
      glxinfo
      vulkan-tools
      glmark2
      wayland
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      bemenu # wayland clone of dmenu
    ];

    security.polkit.enable = true; # needed to run sway with home-manger

    # nvidia (originally from: https://github.com/colemickens/nixcfg/blob/cdd9929d5d36ce5b4d64cf80bdeb1df3f2cba332/mixins/nvidia.nix)
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = nvidiaPackage;
    hardware.nvidia.powerManagement.enable = false;
    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = true;
      displayManager.gdm.nvidiaWayland = true;
    };

    # # kanshi systemd service
    # systemd.user.services.kanshi = {
    #   description = "kanshi daemon";
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    #   };
    # };

    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop).
    # The portal interfaces include APIs for file access, opening URIs,
    # printing and others.
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make gtk apps happy
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
