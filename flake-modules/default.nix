{ system, inputs, lib, ... }:

{
  imports = [
    ./apps.nix
    ./dev.nix
    ./home-manager.nix
    ./nixos.nix
    ./options.nix
    ./overlays.nix
    ./packages.nix
  ];

  flake.lib = import ../lib { inherit lib inputs system; };

}
