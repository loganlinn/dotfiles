{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.loader = {
    timeout = 3;
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
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

  boot.supportedFilesystems = ["ntfs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.enable_psr=1"
    "i915.force_probe=a780"
    # https://lore.kernel.org/linux-pci/20190821124519.71594-1-mika.westerberg@linux.intel.com/
    # https://lore.kernel.org/linux-pci/20190927090202.1468-1-drake@endlessm.com/
    "mem_sleep_default=deep"
  ];
  boot.blacklistedKernelModules = ["spd5118"]; # DDR5 SPD hub temp sensor; fails on resume (ENXIO)
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
