toplevel@{ self, config, inputs, withSystem, lib, ... }:

let

  homeManagerConfiguration = system: modules: ctx@{ config, pkgs, ... }:
    lib.optionalAttrs (ctx.system == system)
      (inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            _module.args.self = self;
            _module.args.inputs = inputs;
            _module.args.lib = ctx.lib.extend { my = self.lib; };

            imports = [ ../home-manager/common.nix ] ++ (lib.toList modules);
            home.username = config.my.user.name;
            home.homeDirectory = config.my.user.home;
            home.packages = config.my.user.packages;

          }
          inputs.nix-colors.homeManagerModule
        ];
      });

in
{

  flake.lib.homeManagerConfiguration = { inherit homeManagerConfiguration; };

  perSystem = ctx: {

    legacyPackages.homeConfigurations = {
      "logan@nijusan" = homeManagerConfiguration "x86_64-linux" ../home-manager/nijusan.nix ctx;
      # "logan@framework" = homeManagerConfiguration "x86_64-linux" ../home-manager/framework.nix ctx;
    };

  };
}
