{ lib, ... }:

{
  flake.lib.my = (import ./extended.nix lib).my;
}
