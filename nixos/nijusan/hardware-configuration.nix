{ inputs, modulesPath, ... }:

{
  # Things to try
  # - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/undervolt.nix
  # - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/fancontrol.nix
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.outputs.nixosModules.common-cpu-intel
    inputs.nixos-hardware.outputs.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.outputs.nixosModules.common-pc-ssd
  ];

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

  swapDevices = [{ device = "/dev/disk/by-uuid/29401b32-91cd-4ab7-b7a4-58ab9a607f59"; }];

  nixpkgs.hostPlatform = "x86_64-linux";
}
