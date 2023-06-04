{ config, lib, pkgs, ... }:

{
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production; # avoid using the bleeding edge here...

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  # https://wiki.archlinux.org/title/Hardware_video_acceleration#Configuring_VA-API
  environment.variables.LIBVA_DRIVER_NAME = "vdpau";
  environment.variables.VDPAU_DRIVER = "nvidia";
  # The direct backend is currently required on NVIDIA driver series 525 due to a regression
  # (see https://github.com/elFarto/nvidia-vaapi-driver/issues/126)
  environment.variables.NVD_BACKEND = "direct";
  # https://github.com/elFarto/nvidia-vaapi-driver/tree/d628720416812b8db9d62519892b3fdb31076ece
  environment.etc."libva.conf".text = ''
    LIBVA_MESSAGING_LEVEL=1
  '';

  environment.systemPackages = with pkgs; [
    libva-utils # vainfo
  ];
}
