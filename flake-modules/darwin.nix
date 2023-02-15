{ self, inputs, lib, ... }:

let


  darwinSystem = modules: ctx@{ options, config, self', inputs', pkgs, system, ... }:
    inputs.darwin.lib.darwinSystem {
      inherit system;
      modules = [
        inputs.home-manager.darwinModules.home-manager
        {
          _module.args.self = self;
          # _module.args.lib = ctx.lib.extend { my = self.lib; };
          imports = lib.toList modules;
        }
      ];
    };
in
{
  perSystem = ctx@{ options, config, self', inputs', pkgs, system, ... }: {
    legacyPackages.darwinConfigurations =
      lib.optionalAttrs (system == "aarch64-darwin") {
        "logan@patchbook" = darwinSystem ../nix-darwin/patchbook.nix ctx;
      };
  };
}
