{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    cue
    cuelsp
  ];
}
