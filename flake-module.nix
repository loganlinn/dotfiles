top@{ self, inputs, moduleWithSystem, withSystem, ... }:

let
  nix-colors = import ./nix-colors/extended.nix inputs;

  mkLib = import ./lib/extended.nix;

  mkHmLib = stdlib:
    import "${inputs.home-manager}/modules/lib/stdlib-extended.nix"
      (mkLib stdlib);

  mkSpecialArgs = { inputs', self', pkgs, lib ? pkgs.lib, ... }: {
    inherit self inputs nix-colors;
    inherit inputs' self';
    lib = mkHmLib lib;
  };

  nixConfig = {
    # TODO move me
    nix.settings = {
      substituters = [
        "https://loganlinn.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "loganlinn.cachix.org-1:CsnLzdY/Z5Btks1lb9wpySLJ60+H9kwFVbcQeb2Pjf8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

in
{
  flake = {
    nixosModules = (import ./nixos/modules) // {
      home-manager = moduleWithSystem (
        systemArgs@{ inputs', self', options, config, pkgs }:
        nixos@{ lib, ... }:
        {
          imports = [ inputs.home-manager.nixosModules.home-manager ];
          config = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = mkSpecialArgs systemArgs;
            home-manager.users.${nixos.config.my.user.name} = { options, config, ... }: {
              options.my = nixos.options.my;
              config.my = nixos.config.my;
            };
          };
        }
      );
    };

    darwinModules = {
      common = import ./nix-darwin/common.nix;
      home-manager = moduleWithSystem (
        systemArgs@{ inputs', self', options, config, pkgs }:
        darwin@{ lib, ... }:
        {
          imports = [ inputs.home-manager.darwinModules.home-manager ];
          config = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = mkSpecialArgs systemArgs;
            home-manager.users.${darwin.config.my.user.name} = { options, config, ... }: {
              options.my = darwin.options.my;
              config.my = darwin.config.my;
            };
          };
        }
      );
    };

    homeModules = {
      common = import ./nix/home/common.nix;
      nix-colors = { lib, ... }: {
        imports = [ nix-colors.homeManagerModule ];
        colorScheme = lib.mkDefault nix-colors.colorSchemes.doom-one;
      };
      secrets = inputs.agenix.homeManagerModules.default;
    };

    lib.dotfiles = {
      mkNixosSystem = system: modules:
        withSystem system (systemArgs@{ self', inputs', config, pkgs, ... }:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = mkSpecialArgs systemArgs;
            modules = [
              ./options.nix
              nixConfig
              {
                nixpkgs.config = pkgs.config;
                nixpkgs.overlays = pkgs.overlays;
              }
            ] ++ modules;
          });

      mkDarwinSystem = system: modules:
        withSystem system (systemArgs@{ self', inputs', config, pkgs, ... }:
          inputs.nix-darwin.lib.darwinSystem {
            inherit pkgs;
            modules = [ ./options.nix nixConfig ] ++ modules;
            specialArgs = mkSpecialArgs systemArgs;
          });

      mkHomeConfiguration =
        systemArgs@{ self', inputs', options, config, pkgs, lib ? pkgs.lib, ... }:
        modules:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit (systemArgs) pkgs lib;
          modules = [
            {
              options.my = systemArgs.options.my;
              config.my = systemArgs.config.my;
            }
          ] ++ modules;
          extraSpecialArgs = mkSpecialArgs systemArgs;
        };

      mkReplAttrs = attrs:
        (builtins // self // {
          inherit self;
          inherit (self.currentSystem) legacyPackages;
          inherit (self.currentSystem.allModuleArgs) # i.e. perSystem module args
            inputs' self' config options system pkgs;
        } // rec {
          lib = mkHmLib top.lib;
          getNixos = { hostname ? lib.my.currentHostname }:
            self.nixosConfigurations.${hostname} or null;
          getDarwin = { hostname ? lib.my.currentHostname }:
            self.darwinConfigurations.${hostname} or null;
          getHome =
            { user ? (builtins.getEnv "USER")
            , hostname ? lib.my.currentHostname
            , system ? builtins.currentSystem
            }:
            let inherit (self.legacyPackages.${system}) homeConfigurations;
            in homeConfigurations."${user}@${hostname}" or homeConfigurations.${user} or homeConfigurations.${hostname} or null;

          nixos = getNixos { };
          darwin = getDarwin { };
          hm = getHome { };
        } // attrs);
    };
  };
}
