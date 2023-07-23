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
  ];
  boot.kernelModules = [
    "kvm-intel"
  ];
  boot.extraModprobeConfig = lib.mkMerge [
    "options snd_hda_intel power_save=1" # idle audio card after one second
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = false; # aggressively autosuspends usb devices. no config available. disable rather than hacking around.
  };
}
