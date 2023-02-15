{ inputs, lib, ... }:

{
  imports = [
    ./home-manager.nix
    ./nixos.nix
    ./darwin.nix
    ./options.nix
    ./overlays
  ];

  flake.lib = import ../lib lib; # TODO push into perSystem

  perSystem = { pkgs, ... }: {

    formatter = pkgs.alejandra;

    devShells.default = inputs.devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [ ../devenv.nix ];
    };

  };
}