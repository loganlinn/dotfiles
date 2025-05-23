{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.lazygit = {
    enable = true;
    settings = {
      gui.enlargedSideViewLocation = "right";
    };
  };
}
