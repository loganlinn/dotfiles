{ inputs, ... }: {
  # imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem = { pkgs, ... }: {

    formatter = pkgs.alejandra;

    devShells.default = inputs.devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        # ../../devenv.nix
        {

          env = {
            NIX_USER_CONF_FILES = toString ../../nix.conf;
          };

          scripts."repl".exec = ''exec nix repl repl.nix "$@"'';

          scripts."switch".exec = ''exec home-manager --flake ~/.dotfiles -b backup "$@"'';

        }
      ];
    };
  };
}
