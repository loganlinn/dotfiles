{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.docker = {
    enable = true;
    enableNvidia = lib.any (x: x == "nvidia") config.services.xserver.videoDrivers;
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
  };
}
