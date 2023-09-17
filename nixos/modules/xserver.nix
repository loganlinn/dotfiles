{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.services.xserver.enable {
    console.useXkbConfig = true;
    services.xserver.layout = "us";
    services.xserver.xkbOptions = "ctrl:nocaps"; # Make Caps Lock a Control key
  };
}
