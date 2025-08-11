{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
{
  home.packages = with pkgs; [
    uv
  ];
}
