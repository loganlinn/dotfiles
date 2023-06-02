{ config, lib, pkgs, ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
  };
}
