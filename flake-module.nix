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

  mkLib = import ./lib/extended.nix;

  mkHmLib = stdlib: import "${inputs.home-manager}/modules/lib/stdlib-extended.nix" (mkLib stdlib);

  mkSpecialArgs = mergeAttrs {
    inherit inputs;
    flake = { inherit self inputs config; };
    nix-colors = import ./nix-colors/extended.nix inputs;
  };

  universalOptions = import ./options.nix;

  universalModule = {
    imports = [
      (import ./nix/nixpkgs.nix self) # configures nixpkgs.overlays
      universalOptions
    ];
  };

in
{
  imports = [
    ./home-manager/flake-module.nix
    ./nixos/flake-module.nix
  ];

  options = {
    perSystem = mkPerSystemOption universalOptions;
  };

  config = {
    perSystem = { pkgs, config, ... }: {
      # imports = [./nix/apps.nix];
      # TODO checks.repl.default = mkNixReplCheck ./repl.nix
    };

    flake = {
      # NixOS home-manager module
      nixosModules = {
        common = {
          imports = [ universalModule ];
        };

        home-manager = {
          imports = [
            inputs.home-manager.nixosModules.home-manager
            ({
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = mkSpecialArgs {
                # rosettaPkgs = import inputs.nixpkgs {system = "x86_64-darwin";};
              };
            })
          ];
        };
      } // (import ./nixos/modules);


      darwinModules.common = {
        imports = [ universalModule ];
      };

      darwinModules.home-manager = {
        imports = [
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = mkSpecialArgs { };
          }
        ];
      };

      homeModules = {
        common = {
          imports = [
            universalModule
            ./nix/home/common.nix
          ];
        };

        basic = {
          imports = [
            universalModule
            ./nix/home/common.nix
            ./nix/home/dev
            ./nix/home/pretty.nix
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

        mkHomeConfiguration = args@{ self', inputs', pkgs, ... }: module:
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = mkSpecialArgs {
              inherit self' inputs';
              lib = mkHmLib args.lib;
            };
            modules = [ module ];
          };

        mkSystemRepl = (builtins // {
          inherit self;
          inherit (self) inputs debug;
          inherit (self.currentSystem) legacyPackages;
          inherit (self.currentSystem.allModuleArgs) inputs' self' config options system pkgs;

          getNixos = { hostname ? lib.my.currentHostname }: self.nixosConfigurations.${hostname};
          getDarwin = { hostname ? lib.my.currentHostname }: self.darwinConfigurations.${hostname};
          getHome = { user ? getEnv ("USER"), hostname ? lib.my.currentHostname, system ? currentSystem }:
            let inherit (flake.legacyPackages.${system}) homeConfigurations; in
              homeConfigurations."${user}@${hostname}"
                or homeConfigurations.${user}
                or homeConfigurations.${hostname};

          nixos = getNixos { };
          darwin = getDarwin { };
          home = getHome { };
        });
      };
    };
  };
}
