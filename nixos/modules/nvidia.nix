{ config, lib, pkgs, ... }:

{
  hardware.nvidia.powerManagement.enable = true;

  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production; # avoid using the bleeding edge here...
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "535.86.05";
    sha256_64bit = "sha256-QH3wyjZjLr2Fj8YtpbixJP/DvM7VAzgXusnCcaI69ts=";
    sha256_aarch64 = "sha256-ON++eWPDWHnm/NuJmDSYkR4sKKvCdX+kwxS7oA2M5zU=";
    openSha256 = "sha256-qCYEQP54cT7G+VrLmuMT+RWIwuGdBhlbYTrCDcztfNs=";
    settingsSha256 = "sha256-0NAxQosC+zPz5STpELuRKDMap4KudoPGWKL4QlFWjLQ=";
    persistencedSha256 = "sha256-Ak4Wf59w9by08QJ0x15Zs5fHOhiIatiJfjBQfnY65Mg=";
  #   version = "535.104.05";
  #   sha256_64bit = "sha256-L51gnR2ncL7udXY2Y1xG5+2CU63oh7h8elSC4z/L7ck=";
  #   sha256_aarch64 = "sha256-J4uEQQ5WK50rVTI2JysBBHLpmBEWQcQ0CihgEM6xuvk=";
  #   openSha256 = "sha256-0ng4hyiUt0rHZkNveFTo+dSaqkMFO4UPXh85/js9Zbw=";
  #   settingsSha256 = "sha256-pS9W5LMenX0Rrwmpg1cszmpAYPt0Mx+apVQmOmLWTog=";
  #   persistencedSha256 = "sha256-uqT++w0gZRNbzyqbvP3GBqgb4g18r6VM3O8AMEfM7GU=";
  };

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
    (writeShellScriptBin "nvidia-driver-version" ''cat /proc/driver/nvidia/version'')
  ];
}
