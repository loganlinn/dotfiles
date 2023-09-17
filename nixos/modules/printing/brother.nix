{ config, lib, pkgs, ... }:

{
  services.printing.drivers = with pkgs; [
    brlaser
    brgenml1lpr
    brgenml1cupswrapper
  ];
}
