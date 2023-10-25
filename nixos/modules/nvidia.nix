{ config, lib, pkgs, ... }:

{
  hardware.nvidia = {
    powerManagement.enable = lib.mkDefault true;
    modesetting.enable = lib.mkDefault true;
    # package = config.boot.kernelPackages.nvidiaPackages.production;
    package = lib.mkDefault (config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "535.86.05";
      sha256_64bit = "sha256-QH3wyjZjLr2Fj8YtpbixJP/DvM7VAzgXusnCcaI69ts=";
      sha256_aarch64 = "sha256-ON++eWPDWHnm/NuJmDSYkR4sKKvCdX+kwxS7oA2M5zU=";
      openSha256 = "sha256-qCYEQP54cT7G+VrLmuMT+RWIwuGdBhlbYTrCDcztfNs=";
      settingsSha256 = "sha256-0NAxQosC+zPz5STpELuRKDMap4KudoPGWKL4QlFWjLQ=";
      persistencedSha256 = "sha256-Ak4Wf59w9by08QJ0x15Zs5fHOhiIatiJfjBQfnY65Mg=";
    });
    prime.nvidiaBusId = lib.mkDefault "PCI:1:0:0";
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  # https://wiki.archlinux.org/title/Hardware_video_acceleration#Configuring_VA-API
  # environment.variables.LIBVA_DRIVER_NAME = "vdpau"; # obs-studio refuses to start when this is set. removing it to see if its still needed...
  # environment.variables.VDPAU_DRIVER = "nvidia";

  # The direct backend is currently required on NVIDIA driver series 525 due to a regression
  # (see https://github.com/elFarto/nvidia-vaapi-driver/issues/126)
  environment.variables.NVD_BACKEND = "direct";
  # https://github.com/elFarto/nvidia-vaapi-driver/tree/d628720416812b8db9d62519892b3fdb31076ece
  environment.etc."libva.conf".text = ''
    LIBVA_MESSAGING_LEVEL=1
  '';

  environment.systemPackages = with pkgs; [
    libva-utils # vainfo
    (writeShellScriptBin "nvidia-driver-version" ''cat /proc/driver/nvidia/version'')
  ];
}
