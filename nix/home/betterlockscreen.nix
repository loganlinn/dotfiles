{ config, lib, pkgs, ... }:

{
  services.betterlockscreen = {
    enable = true;
    arguments = [ "-w" "dim" ];
    inactiveInterval = 15; # minutes
  };
  xdg.configFile."betterlockscreen/betterlockscreenrc".source =
    ../../config/betterlockscreen/betterlockscreenrc;
}
