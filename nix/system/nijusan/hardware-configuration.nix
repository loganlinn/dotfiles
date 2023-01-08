{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "vmd"
    "xhci_pci"
    "ahci"
    "nvme"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "i915.enable_psr=1" "i915.force_probe=a780" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/C7EA-9458";
      fsType = "vfat";
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

    "/etc" = {
      device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
      fsType = "btrfs";
      options = [ "subvol=etc" ];
    };

    "/var/log" = {
      device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
      fsType = "btrfs";
      options = [ "subvol=log" ];
    };

    "/root" = {
      device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/29401b32-91cd-4ab7-b7a4-58ab9a607f59"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno3.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.nvidia.powerManagement.enable = lib.mkDefault true;

  # > With this setting, the NVIDIA GPU driver will allow the GPU to go into its lowest power state when no applications are running that use the nvidia driver stack.
  # > Whenever an application requiring NVIDIA GPU access is started, the GPU is put into an active state.
  # > When the application exits, the GPU is put into a low power state.
  # https://download.nvidia.com/XFree86/Linux-x86_64/460.73.01/README/dynamicpowermanagement.html
  # hardware.nvidia.powerManagement.finegrained = true;

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # https://wiki.archlinux.org/title/Hardware_video_acceleration#Configuring_VA-API
  environment.variables = {
    LIBVA_DRIVER_NAME = lib.mkDefault "vdpau";
    VDPAU_DRIVER = lib.mkDefault "nvidia";
  };

  # Thunderbolt
  services.hardware.bolt.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Sound
  hardware.pulseaudio = {
    enable = true;
    package = lib.mkDefault pkgs.pulseaudioFull;
    support32Bit = true;
  };

  # TODO https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/undervolt.nix
  # TODO https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/fancontrol.nix
}
