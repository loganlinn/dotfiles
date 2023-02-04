{
  description = "loganlinn's (highly indecisive) flake";

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
    # eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";

    # utils
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    debug = true;

    imports = [
      ./home-manager/flake-module.nix
      # ./nix/modules/dev/flake-module.nix
      inputs.treefmt-nix.flakeModule
    ];

    systems = [
      "x86_64-linux"
      "aarch64-darwin"
      # "x86_64-darwin"
      # "aarch64-linux"
    ];

    perSystem = { self', inputs', config, pkgs, system, ... }: rec {
      # make pkgs available to all `perSystem` functions (TODO needed?)
      _module.args.pkgs = inputs'.nixpkgs.legacyPackages;

      formatter = pkgs.alejandra;
    };

    flake = {
      # options.mySystem = lib.mkOption { default = config.allSystems.${builtins.currentSystem}; };

      # homeConfigurations." logan@framework" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = pkgs."x86_64-linux";
      #   modules = [
      #     # ./nix/modules
      #     # ./nix/home/framework.nix
      #     ./nix/hosts/framework/home.nix
      #   ];
      #   extraSpecialArgs = { unstable = pkgs'."x86_64-linux"; };
      # };

      # nixosConfigurations.nijusan = nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     nixos-hardware.nixosModules.common-cpu-intel
      #     nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
      #     nixos-hardware.nixosModules.common-pc-ssd
      #     ./nixos/machines/nijusan
      #   ];
      #   specialArgs = { inherit inputs; };
      # };

      # darwinConfigurations."logan@patchbook" = darwin.lib.darwinSystem {
      #   inherit inputs;
      #   system = "aarch64-darwin";
      #   pkgs = pkgs."aarch64-darwin";
      #   modules = [ ./nix/hosts/patchbook/darwin.nix ];
      # };
    };
  };
}
