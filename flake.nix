{
  description = "loganlinn's nix(os) highly indecisive flake";

  inputs = {

    # package repos
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    # system mangement
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # overlays
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";

    # utils
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";

  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, emacs, darwin, ... }:
    with nixpkgs.lib;
    let
      inherit (home-manager.lib) homeManagerConfiguration;
      inherit (darwin.lib) darwinSystem;

      lib = nixpkgs.lib.extend (self: super: {
        my = import ./nix/lib {
          inherit pkgs inputs;
          lib = self;
        };
      });

      supportedSystems = rec {
        darwin = [ "x86_64-darwin" "aarch64-darwin" ];
        linux = [ "x86_64-linux" "aarch64-linux" ];
        all = darwin ++ linux;
      };

      systems = supportedSystems.all;
      forAllSystems = f: genAttrs systems (system: f system);

      mkPkgs = pkgs: system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ] ++ (attrValues self.overlays);
          config.allowUnfree = true;
        };

      pkgs = forAllSystems (mkPkgs nixpkgs);
      unstable = lib.genAttrs systems (mkPkgs nixpkgs-unstable);

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
          inputs = { inherit darwin nixpkgs; };
        };
    in
    {
      lib = lib.my;

      # packages = forAllSystems (system: import ./nix/pkgs self system);

      overlay = final: prev: { };
      # overlay = forAllSystems (system: _final: _prev: pkgs."${system}");

      # overlay = final: prev: {
      #   unstable = pkgs';
      # };

      overlays = { };
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
        extraSpecialArgs = { unstable = pkgs'."x86_64-linux"; };
      };

      homeConfigurations."logan@framework" = homeManagerConfiguration {
        pkgs = pkgs."x86_64-linux";
        modules = [
          # ./nix/home/framework.nix
          ./nix/hosts/framework/home.nix
        ];
        extraSpecialArgs = { unstable = pkgs'."x86_64-linux"; };
      };

      nixosConfigurations.nijusan = nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          nixos-hardware.nixosModules.common-pc-ssd
          ./nixos/machines/nijusan
        ];
        specialArgs = { inherit inputs; };
      };

      # darwinConfigurations."logan@patchbook" = mkDarwinSystem "aarch64-darwin";
      darwinConfigurations."logan@patchbook" = darwinSystem {
        inherit inputs;
        system = "aarch64-darwin";
        pkgs = pkgs."aarch64-darwin";
        modules = [ ./nix/hosts/patchbook/darwin.nix ];
      };

      devShell = forAllSystems (system: import ./shell.nix { pkgs = pkgs."${system}"; });

      formatter = forAllSystems (system: pkgs.${system}.alejandra);

      templates = import ./nix/templates;
    };
}
