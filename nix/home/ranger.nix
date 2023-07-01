{ config, pkgs, ... }:

{
  home.packages = [ pkgs.ranger ];

  xdg.configFile."ranger/rc.conf".text = ''
    set vcs_aware false
    map zg set vcs_aware true
    setlocal path=${config.xdg.userDirs.download} sort mtime
  '';
}
