toplevel@{ self, inputs, lib, ... }:

let
  inherit (lib) optionalAttrs;
in
{
  perSystem = ctx@{ options, config, self', inputs', pkgs, system, ... }:
    let
      extraSpecialArgs = {
        inherit (inputs) home-manager darwin emacs nix-colors;
        inherit (self.lib) nerdfonts;
      };
      commonModule = {
        imports = [
          inputs.nix-colors.homeManagerModule
          inputs.sops-nix.homeManagerModule
        ];
        options.my = ctx.options.my;
        config = {
          my = ctx.config.my;
          home.username = "logan";
          home.homeDirectory = "/home/logan";
        };
      };
    in
    {
      legacyPackages = (optionalAttrs (system == "x86_64-linux") {
        homeConfigurations."logan@nijusan" = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs extraSpecialArgs;

          modules = [{
            _module.args.self = self;
            _module.args.inputs = inputs;

            imports = [ commonModule ../home-manager/nijusan.nix ];
          }];
        };

        # homeConfigurations."logan@framework" = ...

      }) // (optionalAttrs (system == "aarch64-darwin") {

        darwinConfigurations."logan@patchbook" = inputs.darwin.lib.darwinSystem {
          inherit system;
          modules = [
            inputs.home-manager.darwinModules.home-manager
            {
              _module.args.self = self;
              imports = [ ../nix-darwin/patchbook.nix ];
              home-manager = {
                inherit extraSpecialArgs;
                imports = [ commonModule ];
              };
            }
          ];
        };

      });
    };
}
