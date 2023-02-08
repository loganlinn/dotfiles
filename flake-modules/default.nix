{ system, inputs, lib, ... }@args:

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

  flake.lib = args.callPackage ../lib;
  # flake.lib.types.fontType = inputs.home-manager.lib.hm.types.fontType;

}
