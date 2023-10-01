{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf config.services.xserver.enable {
    console.useXkbConfig = true;
    services.xserver.autorun = mkDefault true;
    services.xserver.layout = "us";
    services.xserver.xkbOptions = "ctrl:nocaps"; # Make Caps Lock a Control key

    #  xkb directory (and the xorg.conf file) gets exported to /etc/X11/xkb, which is useful if you have to often look stuff up in it.
    services.xserver.exportConfiguration = mkDefault true;
  };
}
