{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.btop = {
    settings = {
      color_theme = "onedark";
      theme_background = false;
    };
  };
}
