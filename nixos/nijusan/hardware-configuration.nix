{
  inputs,
  modulesPath,
  ...
}:
{
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

  boot.kernelModules = [ "kvm-intel" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/145be6c5-8187-49cf-949f-982641b12de1";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/AE26-4F32";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/bd669fb1-0d2b-46b2-97af-995f08f8c9f9";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/36f52bc0-725a-4b61-938d-1149fdfd7fc1";
      fsType = "ext4";
    };
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
