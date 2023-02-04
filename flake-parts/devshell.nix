{ inputs, ... }: {
  # imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem = { pkgs, inputs', ... }: {

    formatter = pkgs.alejandra;

    # pre-commit = {
    #   check.enable = true;
    #   settings.hooks = {
    #     alejandra.enable = true;
    #     deadnix.enable = true;
    #     statix.enable = true;
    #   };
    # };

    devShells.default = inputs'.devshell.legacyPackages.mkShell {
      name = "loganlinn/dotfiles";

      # devshell.startup.pre-commit-install.text = config.pre-commit.installationScript;

      packages = [
        pkgs.git
        pkgs.nixVersions.stable
      ];

      commands = [
        {
          name = "repl";
          command = ''
            exec nix repl repl.nix "$@"
          '';
          category = "development";
          help = "Development REPL";
        }
      ];

      env = [
        {
          name = "NIX_USER_CONF_FILES";
          value = toString ../../nix.conf;
        }
      ];
    };
  };
}
