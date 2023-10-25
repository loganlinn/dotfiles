{ config, lib, pkgs, ... }:

{
  boot.loader = {
    timeout = 3;
    systemd-boot = {
      enable = true;
    };

    grub = {
      enable = false; # TODO
      device = "/dev/disk/by-uuid/C7EA-9458";
    };

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
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
  boot.extraModprobeConfig = ''
    "options snd_hda_intel power_save=1" # idle audio card after one second
  '';

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = false; # aggressively autosuspends usb devices. no config available. disable rather than hacking around.
  };
}
