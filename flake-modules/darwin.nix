{ self, inputs, lib, ... }:

let


  darwinSystem = system: modules: ctx@{ config, pkgs, ... }:
    lib.optionalAttrs (system == ctx.system) (inputs.darwin.lib.darwinSystem {
      inherit inputs system pkgs;
      modules = [{
        _module.args.self = self;
        _module.args.inputs = inputs;
        _module.args.lib = ctx.lib.extend { my = self.lib; };
        imports = [ ../nix-darwin/common.nix ] ++ lib.toList modules;
      }];
    });
in
{
  perSystem = ctx: {
    legacyPackages.darwinConfigurations = {

      "logan@patchbook" = darwinSystem "aarch64-darwin" ../nix-darwin/patchbook.nix ctx;

    };
  };
}
