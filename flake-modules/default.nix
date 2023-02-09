{ lib, ... }:

{
  imports = [
    ./dev.nix
    ./home-manager.nix
    ./nixos.nix
    ./options.nix
    ./overlays.nix
  ];

  flake.lib = import ../lib lib;
}
