toplevel@{ self, inputs, lib, ... }:

{
  perSystem = ctx@{ options, config, self', inputs', pkgs, system, ... }:
    let
      inherit (pkgs.stdenv) isLinux isDarwin;

      extraSpecialArgs = {
        inherit (inputs) home-manager darwin emacs nix-colors;
        inherit (self.lib) nerdfonts;
        inherit (config) flake-root;
        flake = self;
        inherit system;
      };

      commonModules = [
        {
          nixpkgs.overlays = [
            inputs.rust-overlay.overlays.default
            inputs.emacs.overlays.default
          ];
        }
        {
          options.my = ctx.options.my;
          config.my = ctx.config.my;
        }
        { _module.args.self = self; }
      ] ++ lib.optionals pkgs.stdenv.isLinux [{
        _module.args.inputs = inputs; # TODO darwin?
      }];

    in
    {
      legacyPackages = (lib.optionalAttrs (system == "x86_64-linux") {

        homeConfigurations."logan@nijusan" =
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs extraSpecialArgs;
            modules = commonModules ++ [
              inputs.nix-colors.homeManagerModule
              inputs.sops-nix.homeManagerModule
              # inputs.emanote.homeManagerModule
              ../home-manager/nijusan.nix
            ];
          };

        # homeConfigurations."logan@framework" = ...

      }) // (lib.optionalAttrs (system == "aarch64-darwin") {

        darwinConfigurations."logan@patchbook" =
          inputs.darwin.lib.darwinSystem {
            inherit system;
            modules = commonModules ++ [
              ../nix-darwin/patchbook.nix
              inputs.home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.logan = { options, config, ... }: {
                  imports = commonModules
                    ++ [ inputs.nix-colors.homeManagerModule ./patchbook.nix ];
                };
                home-manager.extraSpecialArgs = extraSpecialArgs;
              }
            ];
          };
      });
    };
}
