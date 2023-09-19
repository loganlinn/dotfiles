{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf config.services.xserver.enable {
    console.useXkbConfig = true;
    services.xserver.autorun = mkDefault true;
    services.xserver.layout = "us";
    services.xserver.xkbOptions = "ctrl:nocaps"; # Make Caps Lock a Control key
  };
}
