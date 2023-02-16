{self, inputs, lib, ...}: {
  perSystem = ctx @ {options, config, self', inputs', pkgs, system, ...}: {
    legacyPackages.darwinConfigurations =
      lib.optionalAttrs (system == "aarch64-darwin") {
      "logan@patchbook" = inputs.darwin.lib.darwinSystem {
        inherit system;
        modules = [
          inputs.home-manager.darwinModules.home-manager
          {
            _module.args.self = self;
            # _module.args.lib = ctx.lib.extend { my = self.lib; };
            imports = [../nix-darwin/patchbook.nix];
          }
        ];
      };
    };
  };
}
