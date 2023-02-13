toplevel@{ self, config, inputs, withSystem, lib, ... }:

let

  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  hmConfigForSystem = system: module: perSystem@{ self', config, pkgs, ... }:
    lib.optionalAttrs (perSystem.system == system)
      (homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ../home-manager/common.nix
          inputs.nix-colors.homeManagerModule
          {
            _module.args.self = self;
            _module.args.inputs = inputs;

            imports = [ ../home-manager/common.nix ];
            home.username = config.my.user.name;
            home.homeDirectory = config.my.user.home;
            home.packages = config.my.user.packages;

          }
        ] ++ (lib.toList module);
      });

in
{

  perSystem = ctx@{ self', pkgs, ... }: {

    legacyPackages.homeConfigurations = {
      "logan@nijusan" = hmConfigForSystem "x86_64-linux" ../home-manager/nijusan.nix ctx;
      "logan@framework" = hmConfigForSystem "x86_64-linux" ../home-manager/framework.nix ctx;
    };

  };
}
