{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
  };

  hardware.nvidia-container-toolkit.enable =
    lib.any (x: x == "nvidia") config.services.xserver.videoDrivers;
}
