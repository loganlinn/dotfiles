top@{ self, inputs, config, flake-parts-lib, lib, ... }:

with lib;

let
  inherit (flake-parts-lib) mkPerSystemOption;

  nix-colors = import ./nix-colors/extended.nix inputs;

  mkLib = import ./lib/extended.nix;

  mkHmLib = stdlib:
    import "${inputs.home-manager}/modules/lib/stdlib-extended.nix"
    (mkLib stdlib);

  mkSpecialArgs = mergeAttrs {
    inherit self inputs nix-colors;
    nixosModulesPath = toString ./nixos/modules;
    homeModulesPath = toString ./nix/home; # FIXME
    dotfilesPath = toString ./.;
  };

  mkCommonOptions = import ./options.nix;

  mkCommonModule = {
    imports = [
      mkCommonOptions
      {
        # TODO move?
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
      }
    ];
  };

in {
  options = {
    # REVIEW could moduleWithSystem be used instead?
    # https://flake.parts/module-arguments#modulewithsystem
    perSystem = mkPerSystemOption mkCommonOptions;
  };

  config = {
    perSystem = { pkgs, config, ... }:
      {
        # TODO checks.repl.default = mkNixReplCheck ./repl.nix
      };

    flake = {
      # NixOS home-manager module
      nixosModules = recursiveUpdate {
        home-manager = { lib, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = mkSpecialArgs { lib = mkHmLib lib; };
        };

      } (import ./nixos/modules);

      darwinModules = {
        common = { imports = [ mkCommonModule ./nix-darwin/common.nix ]; };

        home-manager = { lib, ... }: {
          imports = [
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs =
                mkSpecialArgs { lib = mkHmLib lib; };
            }
          ];
        };
      };

      homeModules = {
        common = { imports = [ mkCommonModule ./nix/home/common.nix ]; };

        nix-colors = { lib, ... }: {
          imports = [ nix-colors.homeManagerModule ];

          colorScheme = lib.mkDefault nix-colors.colorSchemes.doom-one;
        };

        secrets = { imports = [ inputs.agenix.homeManagerModules.default ]; };
      };

      lib.dotfiles = {
        inherit mkLib mkHmLib mkSpecialArgs;

        mkNixosSystem = system: modules:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ ./options.nix ] ++ modules;
            specialArgs = mkSpecialArgs { };
          };

        mkDarwinSystem = system: modules:
          inputs.nix-darwin.lib.darwinSystem {
            inherit system modules;
            specialArgs = mkSpecialArgs { };
          };

        mkHomeConfiguration = args@{ inputs', self', pkgs, ... }:
          module:
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ module ];
            extraSpecialArgs = mkSpecialArgs {
              inherit inputs' self';
              lib = mkHmLib args.lib;
            };
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
            getHome = { user ? (builtins.getEnv "USER")
              , hostname ? lib.my.currentHostname
              , system ? builtins.currentSystem }:
              let inherit (self.legacyPackages.${system}) homeConfigurations;
              in homeConfigurations."${user}@${hostname}" or homeConfigurations.${user} or homeConfigurations.${hostname} or null;

            nixos = getNixos { };
            darwin = getDarwin { };
            hm = getHome { };
          } // attrs);
      };
    };
  };
}
