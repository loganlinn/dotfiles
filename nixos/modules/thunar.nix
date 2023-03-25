{ config, lib, pkgs, ... }:

let cfg = config.modules.thunar; in
{
  options.modules.thunar = with lib; {
    enable = mkEnableOption "thunar file manager and services";
  };

  config = lib.mkIf cfg.enable {

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };

    services.tumbler.enable = true; # thunar thumbnail support for images

    services.gvfs.enable = true; # thunar mount, trash, and other functionalities

    environment.systemPackages = with pkgs; [
      xfce.thunar
    ];

  };
}
