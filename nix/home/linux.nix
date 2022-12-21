{ pkgs, ... }:

{
  home.packages = with pkgs; [
    sysz
  ];
}
