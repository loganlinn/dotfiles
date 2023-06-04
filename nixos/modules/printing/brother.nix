{ config, lib, pkgs, ... }:

{
  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };
}
