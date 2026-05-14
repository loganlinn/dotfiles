{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    mdsh
    glow
    mermaid-cli
  ];
}
