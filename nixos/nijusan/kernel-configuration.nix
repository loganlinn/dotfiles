{ config, lib, pkgs, ... }:

{
  boot.loader = {
    timeout = 3;

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    # systemd-boot = {
    #   enable = true;
    # };

    grub = {
      enable = true;
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      # set $FS_UUID to the UUID of the EFI partition
      # extraEntries = ''
      #   menuentry "Windows" {
      #     insmod part_gpt
      #     insmod fat
      #     insmod search_fs_uuid
      #     insmod chain
      #     search --fs-uuid --set=root $FS_UUID
      #     chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      #   }
      # '';
      # version = 2;
    };

  };

  boot.plymouth = {
    # enable = false;
    # font = ;
    # logo = ;
    # theme = ;
    # themesPackages = with pkgs; [
    #   catppuccin-plymouth
    #   adi1090x-plymouth-themes
    #   nixos-bgrt-plymouth
    # ];
  };

  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.enable_psr=1"
    "i915.force_probe=a780"
    # https://lore.kernel.org/linux-pci/20190821124519.71594-1-mika.westerberg@linux.intel.com/
    # https://lore.kernel.org/linux-pci/20190927090202.1468-1-drake@endlessm.com/
    "mem_sleep_default=deep"
  ];
  boot.kernelModules = [
    "kvm-intel"
    "v4l2loopback"
  ];
  boot.extraModulePackages = [
    # config.boot.kernelPackages.exfat-nofuse
  ];
  boot.extraModprobeConfig = ''
    "options snd_hda_intel power_save=1" # idle audio card after one second
  '';

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = false; # aggressively autosuspends usb devices. no config available. disable rather than hacking around.
  };
}
