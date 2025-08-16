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
  home.sessionVariables = {
    UV_VENV_SEED = "1"; # `uv venv` seed with pip by default
  };
}
