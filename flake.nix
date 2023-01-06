{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    # nixos-hardware.url = "github:nixos/nixos-hardware";

    # flake-utils.url = "github:numtide/flake-utils";

    # bad-hosts.url = github:StevenBlack/hosts;
    # bad-hosts.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # agenix.url = "github:ryantm/agenix";

    # devenv.url = "github:cachix/devenv/v0.5";
    # devenv.inputs.nixpkgs.follows = "nixpkgs";

    # neovim-flake.url = "github:jordanisaacs/neovim-flake";
    # neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    # flake-utils,
    home-manager,
    emacs,
    darwin,
    ...
  }: let
    # inherit (lib) genAttrs;
    # inherit (lib.my) mapModules mapModulesRec mapHosts mapConfigurations;
    inherit (nixpkgs.lib) nixosSystem genAttrs;
    inherit (home-manager.lib) homeManagerConfiguration;
    inherit (darwin.lib) darwinSystem;

    flake = builtins.getFlake (toString ./.);
    lib = nixpkgs.lib;
    # lib = nixpkgs.lib.extend (self: super: {
    #   my = import ./nix/lib {
    #     inherit pkgs inputs darwin;
    #     lib = self;
    #   };
    # });

    supportedSystems = rec {
      darwin = ["x86_64-darwin" "aarch64-darwin"];
      linux = ["x86_64-linux" "aarch64-linux"];
      all = darwin ++ linux;
    };

    mkPkgs = pkgs: extraOverlays: system:
      import nixpkgs {
        inherit system;
        overlays = extraOverlays ++ lib.attrValues self.overlays;
        config = {
          allowUnfree = true;
        };
      };

    pkgs = genAttrs supportedSystems.all (mkPkgs nixpkgs [self.overlay]);
    pkgs' = genAttrs supportedSystems.all (mkPkgs nixpkgs-unstable [self.overlay]);

    mkDarwinSystem = system:
      darwinSystem {
        inherit system;
        pkgs = mkPkgs nixpkgs [] system;
        modules = [
          home-manager.darwinModules.home-manager
          ./nix/darwin/configuration.nix
          {
            home-manager.users.logan = import ./nix/home/darwin.nix;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
        inputs = {inherit darwin nixpkgs;};
      };
  in {
    overlay = final: prev: {
      unstable = pkgs';
    };

    overlays = {};

    homeConfigurations."logan@nijusan" = homeManagerConfiguration {
      pkgs = pkgs."x86_64-linux";
      modules = [
        ./nix/home/nijusan.nix
      ];
    };

    homeConfigurations."logan@framework" = homeManagerConfiguration {
      pkgs = pkgs."x86_64-linux";
      modules = [
        ./nix/home/framework.nix
      ];
    };

    nixosConfigurations.nijusan = nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nix/system/nijusan
        {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
        }
      ];
      specialArgs = {inherit inputs;};
    };

    darwinConfigurations."logan@patchbook" = mkDarwinSystem "aarch64-darwin";

    formatter = genAttrs supportedSystems.all (system: pkgs.${system}.alejandra);

    # # Executed by `nix flake check`
    # checks."<system>"."<name>" = derivation;

    # # Executed by `nix build .#<name>`
    # packages."<system>"."<name>" = derivation;

    # # Executed by `nix build .`
    # packages."<system>".default = derivation;
    # # Executed by `nix run .#<name>`
    # apps."<system>"."<name>" = {
    #   type = "app";
    #   program = "<store-path>";
    # };
    # # Executed by `nix run . -- <args?>`
    # apps."<system>".default = { type = "app"; program = "..."; };

    # # Used for nixpkgs packages, also accessible via `nix build .#<name>`
    # legacyPackages."<system>"."<name>" = derivation;
    # # Overlay, consumed by other flakes
    # overlays."<name>" = final: prev: { };
    # # Default overlay
    # overlays.default = {};
    # # Nixos module, consumed by other flakes
    # nixosModules."<name>" = { config }: { options = {}; config = {}; };
    # # Default module
    # nixosModules.default = {};
    # # Used with `nixos-rebuild --flake .#<hostname>`
    # # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation
    # nixosConfigurations."<hostname>" = {};
    # # Used by `nix develop .#<name>`
    # devShells."<system>"."<name>" = derivation;
    # # Used by `nix develop`
    # devShells."<system>".default = derivation;
    # # Hydra build jobs
    # hydraJobs."<attr>"."<system>" = derivation;
    # # Used by `nix flake init -t <flake>#<name>`
    # templates."<name>" = {
    #   path = "<store-path>";
    #   description = "template description goes here?";
    # };
    # # Used by `nix flake init -t <flake>`
    # templates.default = { path = "<store-path>"; description = ""; };
  };
}
