{ inputs, lib, ... }:

{
  imports = [
    ./home-manager.nix
    ./nixos.nix
    ./options.nix
    ./overlays
  ];

  flake.lib = import ../lib lib; # TODO push into perSystem

  perSystem = { inputs', pkgs, ... }: {

    formatter = pkgs.alejandra;

    devShells.default = inputs'.devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [ ../devenv.nix ];
    };

  };
}
