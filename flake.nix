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
    # neovim-flake,
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
    # $ darwin-rebuild build --flake ~/.dotfiles#patbook --override-input darwin .
    darwinConfigurations."logan@patbook" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        ./nix/darwin/patbook.nix
        {
          home-manager.users.logan = import ./nix/home/patbook.nix;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."patbook".pkgs;
  };
}
# Acknowledgements
# - https://gitlab.com/rprospero/dotfiles/-/blob/master/flake.nix

