{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.thunar = {
    enable = lib.mkDefault true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  # thumbnail service
  services.tumbler.enable = lib.mkDefault config.programs.thunar.enable;

  # thunar mount, trash, and other functionalities
  services.gvfs.enable = lib.mkDefault config.programs.thunar.enable;

  environment.systemPackages = with pkgs; [
    xfce.thunar
  ];
}
