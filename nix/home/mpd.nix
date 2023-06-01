{ config, lib, pkgs, ... }:

{
  services.mpd = {
    musicDirectory = config.xdg.userDirs.music;
  };
}
