top@{ self, inputs, options, config, lib, moduleWithSystem, withSystem, ... }:

with lib;

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

  sharedModule = {
    nixpkgs.overlays = [
      inputs.emacs-overlay.overlays.default
      inputs.fenix.overlays.default
    ];

    nix.settings = {
      substituters = [
        "https://loganlinn.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "loganlinn.cachix.org-1:CsnLzdY/Z5Btks1lb9wpySLJ60+H9kwFVbcQeb2Pjf8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

in
{
  perSystem = import ./options.nix;

  flake = {
    # NixOS home-manager module
    nixosModules = (import ./nixos/modules) // {
      home-manager = moduleWithSystem (
          perSystem@{ inputs', self', options, config, pkgs }:
          nixos@{ lib, ... }:
          {
            imports = [ inputs.home-manager.nixosModules.home-manager ];
            config = {
              inherit (perSystem.config) my;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = mkSpecialArgs perSystem;
              home-manager.users.${perSystem.config.my.user.name} = { options, config, ... }: {
                # imports = lib.toList perSystem.config.my.homeModules;
                options.my = perSystem.options.my;
                config.my = perSystem.config.my;
              };
            };
          }
        );
    };

    darwinModules = {
      common = import ./nix-darwin/common.nix;
      home-manager = moduleWithSystem (
        perSystem@{ inputs', self', config, pkgs }:
        darwin@{ lib, ... }:
        {
          imports = [ inputs.home-manager.darwinModules.home-manager ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = mkSpecialArgs perSystem;
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
      inherit mkLib mkHmLib;

      mkNixosSystem = system: modules:
        withSystem system (ctx@{ self', inputs', config, pkgs, ... }:
          inputs.nixpkgs.lib.nixosSystem {
            inherit pkgs;
            modules = [ ./options.nix sharedModule ] ++ modules;
            specialArgs = mkSpecialArgs ctx;
          });

      mkDarwinSystem = system: modules:
        withSystem system (ctx@{ self', inputs', config, pkgs, ... }:
          inputs.nix-darwin.lib.darwinSystem {
            inherit pkgs;
            modules = [ ./options.nix sharedModule ] ++ modules;
            specialArgs = mkSpecialArgs ctx;
          });

      mkHomeConfiguration = ctx@{ self', inputs', config, pkgs, ... }:
        modules:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit (ctx) pkgs;
          modules = [
            {
              options.my = ctx.options.my;
              config.my = ctx.config.my;
            }
          ] ++ modules;
          extraSpecialArgs = mkSpecialArgs ctx;
        };

      mkReplAttrs = attrs:
        (builtins // self // {
          inherit self;
          inherit (self.currentSystem) legacyPackages;
          inherit (self.currentSystem.allModuleArgs) # i.e. perSystem module context
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
