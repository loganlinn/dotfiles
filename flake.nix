{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    # nur.url = "github:nix-community/NUR";
    # nur.inputs.nixpkgs.follows = "nixpkgs";

    # flake-utils.url = "github:numtide/flake-utils";

    # bad-hosts.url = github:StevenBlack/hosts;
    # bad-hosts.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

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
    nixos-hardware,
    # nur,
    # flake-utils,
    home-manager,
    agenix,
    emacs,
    darwin,
    ...
  }: let
    # inherit (lib) genAttrs;
    # inherit (lib.my) mapModules mapModulesRec mapHosts mapConfigurations;
    inherit (nixpkgs.lib) nixosSystem genAttrs mkIf;
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

    systems = supportedSystems.all;

    forAllSystems = f: genAttrs systems (system: f system);

    mkPkgs = pkgs: extraOverlays: system:
      import nixpkgs {
        inherit system;
        overlays = extraOverlays ++ lib.attrValues self.overlays;
        config = {
          allowUnfree = true;
        };
      };

    pkgs = genAttrs systems (mkPkgs nixpkgs [self.overlay]);
    pkgs' = genAttrs systems (mkPkgs nixpkgs-unstable [self.overlay]);

    mkDarwinSystem = system:
      darwinSystem {
        inherit system;
        pkgs = pkgs."${system}";
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
    # lib = nixpkgs.lib;
    # lib = import ./lib { inherit inputs; } // inputs.nixpkgs.lib;

    # packages = forAllSystems (system: import ./nix/pkgs self system);

    overlay = _final: _prev: { };
    # overlay = forAllSystems (system: _final: _prev: pkgs."${system}");

    # overlay = final: prev: {
    #   unstable = pkgs';
    # };

    overlays = {};
    # overlays = forAllSystems (system:
    #   [
    #     (self.overlay."${system}")
    #     (nur.overlay)
    #   ]
    # );

    homeConfigurations."logan@nijusan" = homeManagerConfiguration {
      pkgs = pkgs."x86_64-linux";
      modules = [
        ./nix/hosts/nijusan/home.nix
      ];
      extraSpecialArgs = {unstable = pkgs'."x86_64-linux";};
    };

    homeConfigurations."logan@framework" = homeManagerConfiguration {
      pkgs = pkgs."x86_64-linux";
      modules = [
        # ./nix/home/framework.nix
        ./nix/hosts/framework/home.nix
      ];
      extraSpecialArgs = {unstable = pkgs'."x86_64-linux";};
    };

    nixosConfigurations.nijusan = nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
        nixos-hardware.nixosModules.common-pc-ssd
        # nur.nixosModules.nur
        ./nix/system/nijusan
        {
          system.configurationRevision = mkIf (self ? rev) self.rev;
        }
        agenix.nixosModule
      ];
      specialArgs = {inherit inputs;};
    };

    # darwinConfigurations."logan@patchbook" = mkDarwinSystem "aarch64-darwin";
    darwinConfigurations."logan@patchbook" = darwinSystem {
      inherit inputs;
      system = "aarch64-darwin";
      pkgs = pkgs."aarch64-darwin";
      modules = [./nix/hosts/patchbook/darwin.nix];
    };

    devShell = forAllSystems (system: import ./shell.nix { pkgs = pkgs."${system}"; });

    formatter = forAllSystems (system: pkgs.${system}.alejandra);

    templates = import ./nix/templates;
  };
}
