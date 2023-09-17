top@{ self
, inputs
, config
, flake-parts-lib
, lib
, ...
}:

with lib;

let
  inherit (flake-parts-lib) mkPerSystemOption;

  nix-colors = import ./nix-colors/extended.nix inputs;

  mkLib = import ./lib/extended.nix;

  mkHmLib = stdlib: import "${inputs.home-manager}/modules/lib/stdlib-extended.nix" (mkLib stdlib);

  mkSpecialArgs = mergeAttrs {
    inherit inputs nix-colors;
    flake = { inherit self inputs config; };
    nixosModulesPath = toString ./nixos/modules;
    homeModulesPath = toString ./nix/home; # FIXME
  };

  mkCommonOptions = import ./options.nix;

  mkCommonModule = {
    imports = [
      mkCommonOptions
      {
        nixpkgs.overlays = [
          self.overlays.default
          inputs.rust-overlay.overlays.default
          inputs.emacs-overlay.overlays.default
        ];
      }
    ];
  };

in
{
  options = {
    # REVIEW could moduleWithSystem be used instead?
    # https://flake.parts/module-arguments#modulewithsystem
    perSystem = mkPerSystemOption mkCommonOptions;
  };

  config = {
    perSystem = { pkgs, config, ... }: {
      # imports = [./nix/apps.nix];
      # TODO checks.repl.default = mkNixReplCheck ./repl.nix
    };

    flake = {
      # NixOS home-manager module
      nixosModules = recursiveUpdate {
        common = {
          imports = [ mkCommonModule ];
        };

        home-manager = {
          imports = [
            inputs.home-manager.nixosModules.home-manager
            (args: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = mkSpecialArgs {
                lib = mkHmLib args.lib;
              };
            })
          ];
        };

        secrets = {
          imports = [ inputs.agenix.nixosModules.default ];
        };

      } (import ./nixos/modules);


      darwinModules = {
        common = {
          imports = [ mkCommonModule ];
        };

        home-manager = {
          imports = [
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = mkSpecialArgs { };
            }
          ];
        };
      };

      homeModules = {
        common = {
          imports = [
            mkCommonModule
            ./nix/home/common.nix
          ];
        };

        nix-colors = nix-colors.homeManagerModule;

        basic = {
          imports = [
            mkCommonModule
            ./nix/home/common.nix
            ./nix/home/dev
            ./nix/home/pretty.nix
          ];
        };

        secrets = {
          imports = [
            inputs.agenix.homeManagerModules.default
          ];
        };
      };


      lib.dotfiles = {
        inherit
          mkLib
          mkHmLib
          ;

        mkNixosSystem = system: module:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = mkSpecialArgs { inherit self; }; # TODO consolidate flake vs self
            modules = [ module ];
          };

        mkDarwinSystem = system: module:
          inputs.nix-darwin.lib.darwinSystem {
            inherit system;
            specialArgs = mkSpecialArgs {
              # rosettaPkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };
            };
            modules = [ module ];
          };

        mkHomeConfiguration = args@{ inputs', self', pkgs, ... }: module:
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = mkSpecialArgs {
              lib = mkHmLib args.lib;
              inputs' = # lib.warn "Stop using inputs' outside of flake-module"
                inputs';
              self' = # lib.warn "Stop using self' outside of flake-module"
                self';
            };
            modules = [ module ];
          };

        mkReplAttrs = attrs: (
          builtins
          // self
          // {
            inherit
              self;
            inherit (self.currentSystem)
              legacyPackages;
            inherit (self.currentSystem.allModuleArgs) # i.e. perSystem module context
              inputs'
              self'
              config
              options
              system
              pkgs;
          }
          // rec {
            lib = mkHmLib top.lib;
            getNixos = { hostname ? lib.my.currentHostname }: self.nixosConfigurations.${hostname} or null;
            getDarwin = { hostname ? lib.my.currentHostname }: self.darwinConfigurations.${hostname} or null;
            getHome = { user ? (builtins.getEnv "USER"), hostname ? lib.my.currentHostname, system ? builtins.currentSystem }:
              let inherit (self.legacyPackages.${system}) homeConfigurations; in
                homeConfigurations."${user}@${hostname}"
                  or homeConfigurations.${user}
                  or homeConfigurations.${hostname}
                  or null;

            nixos = getNixos { };
            darwin = getDarwin { };
            hm = getHome { };
          }
          // attrs
        );
      };
    };
  };
}
