{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    crystal
    icr
    shards
  ];
}
