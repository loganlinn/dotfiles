{ inputs, ... }: {

  perSystem = { pkgs, ... }: {

    formatter = pkgs.alejandra;

    devShells.default = inputs.devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [ ../devenv.nix ];
    };

  };
}
