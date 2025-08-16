{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    elixir
    elixir-ls
  ];
}
