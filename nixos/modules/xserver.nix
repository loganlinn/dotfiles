{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.services.xserver.enable {
    services.xserver.layout = "us";
    services.xserver.xkbOptions = "ctrl:nocaps"; # Make Caps Lock a Control key
  };
}
