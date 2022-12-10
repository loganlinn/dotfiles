{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["vmd" "xhci_pci" "ahci" "nvme" "thunderbolt" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["i915"];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.enable_psr=0"
    "i915.force_probe=a780"
  ];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C7EA-9458";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
    fsType = "btrfs";
    options = ["subvol=nix"];
  };

  fileSystems."/etc" = {
    device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
    fsType = "btrfs";
    options = ["subvol=etc"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
    fsType = "btrfs";
    options = ["subvol=log"];
  };

  fileSystems."/root" = {
    device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
    fsType = "btrfs";
    options = ["subvol=root"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/b5ce2531-a3ee-476e-930e-83b6ecef2609";
    fsType = "btrfs";
    options = ["subvol=home"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/29401b32-91cd-4ab7-b7a4-58ab9a607f59";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno3.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl
    intel-media-driver
  ];

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };
}
