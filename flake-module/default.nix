top@{
  self,
  inputs,
  moduleWithSystem,
  withSystem,
  ...
}:

let
  nix-colors = import ../nix-colors/extended.nix inputs;

  mkLib = baseLib: extendLibHm (extendLibMy baseLib);
  extendLibMy = import ../lib/extended.nix;
  extendLibHm = import "${inputs.home-manager}/modules/lib/stdlib-extended.nix";

  mkSpecialArgs =
    {
      inputs',
      self',
      pkgs,
      lib ? pkgs.lib,
      ...
    }:
    {
      inherit self inputs nix-colors;
      inherit inputs' self';
      lib = mkLib lib;
    };

    mkNixosSystem =
      system: modules:
      withSystem system (
        systemArgs@{
          self,
          self',
          inputs',
          config,
          pkgs,
          ...
        }:
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
        }
      );

    mkHomeConfiguration =
      # systemArgs@{
      #   self',
      #   inputs',
      #   options,
      #   config,
      #   pkgs,
      #   lib,
      #   ...
      # }:
      systemArgs:
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

    mkDarwinSystem =
      system: modules:
      withSystem system (
        systemArgs@{
          self,
          self',
          inputs',
          config,
          pkgs,
          ...
        }:
        inputs.nix-darwin.lib.darwinSystem {
          inherit pkgs;
          modules = [ ../options.nix ] ++ modules;
          specialArgs = mkSpecialArgs systemArgs;
        }
      );

    mkReplAttrs =
      {
        user ? (builtins.getEnv "USER"),
        hostname ? (mkLib top.lib).currentHostname,
        system ? builtins.currentSystem,
      }:
      builtins
      // self
      // rec {
        inherit self;
        inherit (self.currentSystem) legacyPackages;
        inherit (self.currentSystem.allModuleArgs) # i.e. perSystem module args
          inputs'
          self'
          config
          options
          system
          pkgs
          ;
        lib = mkLib pkgs.lib;
        nixos = self.nixosConfigurations.${hostname} or null;
        darwin = self.darwinConfigurations.${hostname} or null;
        hm =
          # home-manager "standalone" installation
          legacyPackages.homeConfigurations."${user}@${hostname}" or legacyPackages.homeConfigurations.${user}
            or legacyPackages.homeConfigurations.${hostname}
              # home-manager "nixos module" installation
              or nixos.config.home-manager.users.${user}
                # ¯\_(ツ)_/¯
                or null;
      };

in
{
  imports = [
    ./mission-control.nix
  ];

  flake.lib = {
    inherit mkSpecialArgs mkNixosSystem mkHomeConfiguration mkDarwinSystem mkReplAttrs;
    my = (mkLib top.lib).my;
  };

  flake.nixosModules = import ../nixos/modules;

  # NB: 'homeModules' preferred over 'homeManagerModules', see https://github.com/NixOS/nix/blob/af26fe39344faff70e009d980820b8667c319cb2/src/nix/flake.cc#L810-L811
  flake.homeModules = {
    common = import ../nix/home/common.nix;
    nix-colors =
      { lib, ... }:
      {
        imports = [ nix-colors.homeManagerModule ];
        colorScheme = lib.mkDefault nix-colors.colorSchemes.doom-one;
      };
    secrets = inputs.agenix.homeManagerModules.default;
  };

  flake.darwinModules = {
    common = import ../nix-darwin/common.nix;
    home-manager = moduleWithSystem (
      systemArgs@{
        inputs',
        self,
        self',
        options,
        config,
        pkgs,
      }:
      darwin@{ lib, ... }:
      {
        imports = [ inputs.home-manager.darwinModules.home-manager ];
        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = mkSpecialArgs systemArgs;
          home-manager.users.${darwin.config.my.user.name} =
            { options, config, ... }:
            {
              options.my = darwin.options.my;
              config.my = darwin.config.my;
            };
        };
      }
    );
  };
}
