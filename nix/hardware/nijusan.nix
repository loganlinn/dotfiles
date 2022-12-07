{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {

  boot.kernelParams = [
    "i915.enable_psr=1"
    "i915.force_probe=a780"
  ];

  # nixpkgs.config.packageOverrides = pkgs: {
  #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true;  };
  # };
  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #     vaapiIntel         # LIBVA_DRIVER_NAME=i964
  #     vaapiVdpau
  #     libvdpau-va-gl
  #   ];
  # };
}
