top@{ self, inputs, moduleWithSystem, withSystem, ... }:

let
  nix-colors = import ../nix-colors/extended.nix inputs;

  mkLib = import ../lib/extended.nix;

  mkHmLib = stdlib:
    import "${inputs.home-manager}/modules/lib/stdlib-extended.nix"
      (mkLib stdlib);

  mkSpecialArgs = { inputs', self', pkgs, lib ? pkgs.lib, ... }: {
    inherit self inputs nix-colors;
    inherit inputs' self';
    lib = mkHmLib lib;
  };
in
{
  imports = [
    ./mission-control.nix
    ./sops.nix
    { flake.nixosModules = import ../nixos/modules; }
  ];

  flake = {
    nixosModules = {
      home-manager = moduleWithSystem (
        systemArgs@{ inputs', self', options, config, pkgs }:
        nixos@{ lib, ... }:
        {
          imports = [
            inputs.home-manager.nixosModules.home-manager
          ];
          config = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = mkSpecialArgs systemArgs;
            home-manager.users.${nixos.config.my.user.name} = { options, config, ... }: {
              options.my = nixos.options.my;
              config.my = nixos.config.my;
            };
            home-manager.backupFileExtension = "backup";
          };
        }
      );
    };

    darwinModules = {
      common = import ../nix-darwin/common.nix;
      home-manager = moduleWithSystem (
        systemArgs@{ inputs', self', options, config, pkgs }:
        darwin@{ lib, ... }:
        {
          imports = [
            inputs.home-manager.darwinModules.home-manager
          ];
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

    # 'homeManagerModule' is often used, but 'homeModule' is the preferred name according to `nix` command:
    # https://github.com/NixOS/nix/blob/af26fe39344faff70e009d980820b8667c319cb2/src/nix/flake.cc#L810-L811
    homeModules = {
      common = import ../nix/home/common.nix;
      nix-colors = { lib, ... }: {
        imports = [ nix-colors.homeManagerModule ];
        colorScheme = lib.mkDefault nix-colors.colorSchemes.doom-one;
      };
      secrets = inputs.agenix.homeManagerModules.default;
    };

    lib = rec {
      my = (mkHmLib top.lib).my;
      dotfiles = {
        mkNixosSystem = system: modules:
          withSystem system (systemArgs@{ self', inputs', config, pkgs, ... }:
            inputs.nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = mkSpecialArgs systemArgs;
              modules = [
                ../options.nix
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
              modules = [ ../options.nix ] ++ modules;
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

        mkReplAttrs =
          { user ? (builtins.getEnv "USER")
          , hostname ? my.currentHostname
          , system ? builtins.currentSystem
          }:
          builtins //
          self //
          rec {
            inherit self;
            inherit (self.currentSystem)
              legacyPackages;
            inherit (self.currentSystem.allModuleArgs) # i.e. perSystem module args
              inputs'
              self'
              config
              options
              system
              pkgs;
            lib = mkHmLib pkgs.lib;
            nixos = self.nixosConfigurations.${hostname} or null;
            darwin = self.darwinConfigurations.${hostname} or null;
            hm =
              # home-manager "standalone" installation
              legacyPackages.homeConfigurations."${user}@${hostname}"
                or legacyPackages.homeConfigurations.${user}
                or legacyPackages.homeConfigurations.${hostname}
                # home-manager "nixos module" installation
                or nixos.config.home-manager.users.${user}
                # ¯\_(ツ)_/¯
                or null;
          };
      };
    };
  };
}
