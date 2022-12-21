{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    emacs,
    darwin,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    homeConfigurations."logan@nijusan" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [./nix/home/nijusan.nix];
    };

    homeConfigurations."logan@framework" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./nix/home/framework.nix
      ];
    };

    nixosConfigurations."nijusan" = nixpkgs.lib.nixosSystem {
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

    # Build darwin flake using:
    # $ darwin-rebuild build --flake ~/.darwin#patbook --override-input darwin .
    darwinConfigurations."patbook" = let
      configuration = {pkgs, ...}: {
        # nix.package = pkgs.nixVersions.stable;

        services.nix-daemon.enable = true;
      };
    in
      darwin.lib.darwinSystem {
        modules = [configuration darwin.darwinModules.simple];
        system = "aarch64-darwin";
      };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."simple".pkgs;
  };
}
# Acknowledgements
# - https://gitlab.com/rprospero/dotfiles/-/blob/master/flake.nix

