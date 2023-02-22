toplevel@{ self, inputs, lib, ... }:

let
  inherit (lib) optionalAttrs;
in
{
  perSystem = ctx@{ options, config, self', inputs', pkgs, system, ... }:
    let
      extraSpecialArgs = {
        inherit (inputs) home-manager darwin emacs nix-colors fzf-git;
        inherit (self.lib) nerdfonts;
      };
    in
    {
      legacyPackages = (optionalAttrs (system == "x86_64-linux") {
        homeConfigurations."logan@nijusan" = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs extraSpecialArgs;

          modules = [
            inputs.nix-colors.homeManagerModule
            {
              _module.args.self = self;
              _module.args.inputs = inputs;

              imports = [
                ../home-manager/nijusan.nix
              ];

              home.username = "logan";
              home.homeDirectory = "/home/logan";
            }
          ];
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
              };
            }
          ];
        };

      });
    };
}
