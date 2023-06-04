toplevel@{ self, inputs, ... }:

let

in
{
  # flake = rec {
  #   homeManagerModules.default = import ./module.nix;
  #   homeManagerModule = homeManagerModules.default;
  # };

  perSystem = ctx@{ options, config, self', inputs', pkgs, lib, system, ... }:
    let
      inherit (pkgs.stdenv) isLinux isDarwin;

      extraSpecialArgs = {
        inherit (inputs) nixpkgs home-manager emacs;
        inherit (config) flake-root;
        flake = self; # remove usage
        nerdfonts = import ../lib/nerdfonts;
        nix-colors = import ../nix-colors/extended.nix inputs;
      };

      commonModules = [
        {
          options.my = ctx.options.my;
          config.my = ctx.config.my;
        }
        {
          nixpkgs.overlays = [
            inputs.rust-overlay.overlays.default
            inputs.emacs.overlays.default
          ];
        }
      ];
    in
    {
      legacyPackages =
        (lib.optionalAttrs (system == "x86_64-linux") {
          homeConfigurations."logan@nijusan" = inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs lib extraSpecialArgs;
            modules =
              commonModules
              ++ [
                inputs.sops-nix.homeManagerModule
                # inputs.emanote.homeManagerModule
                ../home-manager/nijusan.nix
              ];
          };
        })
        // (lib.optionalAttrs (system == "aarch64-darwin") {
          darwinConfigurations."logan@patchbook" = inputs.darwin.lib.darwinSystem {
            inherit lib system;
            # FIXME: commonModules should be used in both...
            modules = commonModules ++ [
              ../nix-darwin/patchbook.nix
              inputs.home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = extraSpecialArgs;
                home-manager.users.logan = { options, config, ... }: {
                  imports = commonModules ++ [ ./patchbook.nix ];
                };
              }
            ];
          };
        });
    };
}
