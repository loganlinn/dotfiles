{ config, lib, pkgs, ... }:

with lib;

{
  services.dunst = {
    enable = mkDefault true;
  };
}
