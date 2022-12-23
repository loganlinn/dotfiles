{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv/v0.5";

    # neovim-flake.url = "github:jordanisaacs/neovim-flake";
    # neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    emacs,
    darwin,
    devenv,
    # neovim-flake,
    ...
  }: let
    inherit (nixpkgs.lib) nixosSystem;
    inherit (home-manager.lib) homeManagerConfiguration;
    inherit (darwin.lib) darwinSystem;

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

    mkDarwinSystem = system:
      darwinSystem {
        inherit system;
        pkgs = mkPkgs system;
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

  in {
    homeConfigurations.nijusan = let
      system = "x86_64-linux";
    in
      homeManagerConfiguration {
        inherit system;
        pkgs = mkPkgs system;
        modules = [
          ./nix/home/nijusan.nix
        ];
      };

    homeConfigurations.framework = let
      system = "x86_64-linux";
    in
      homeManagerConfiguration {
        inherit system;
        pkgs = mkPkgs system;
        modules = [
          ./nix/home/framework.nix
        ];
      };

    nixosConfigurations.nijusan = let
      system = "x86_64-linux";
    in
      nixosSystem {
        inherit system;
        modules = [
          ./nix/hardware/nijusan.nix
          ./nix/system/nijusan.nix
          ./nix/system/logan.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

    darwinConfigurations.patchbook = mkDarwinSystem "aarch64-darwin";

    packages.x86_64-linux = [devenv.packages.x86_64-linux.devenv];
    # packages.aarch64-darwin = [devenv.packages.aarch64-darwin.devenv];

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
