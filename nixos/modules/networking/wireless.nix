{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf config.networking.wireless.enable {
    networking.wireless.scanOnLowSignal = mkDefault false;
    networking.wireless.allowAuxiliaryImperativeNetworks = mkDefault true;
    networking.wireless.userControlled.enable = mkDefault true;
  };
}
