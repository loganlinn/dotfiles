{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    emacs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations."logan@nijusan" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./nix/home/nijusan.nix ];
    };

    #homeConfigurations = {
    # "logan@framework" = home-manager.lib.homeManagerConfiguration {
    #   pkgs = nixpkgs.legacyPackages."x86_64-linux";
    #   modules = [
    #     ./nix/home/framework.nix
    #   ];
    # };

    nixosConfigurations.nijusan = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./nix/hardware/nijusan.nix
        ./nix/system/nijusan.nix
        ./nix/system/logan.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          #home-manager.extraSpecialArgs = { inherit nixpkgs emacs; };
        }
      ];
    };

    # nixosConfigurations.patbook = nixpkgs.lib.nixosSystem {
    #   system = "aarch64-darwin";
    #   modules = [
    #     ./nix/hardware/mbp-2021.nix
    #     ./nix/system/mouse.nix
    #   ];
    #   specialArgs = { };
    # };
    # nixosConfigurations.mouse = nixpkgs.lib.nixosSystem {
    #   system = "aarch64-linux";
    #   modules = [
    #     ./nix/hardware/mouse.nix
    #     ./nix/system/mouse.nix
    #   ];
    #   specialArgs = { };
    # };
  };
}
# Acknowledgements
# - https://gitlab.com/rprospero/dotfiles/-/blob/master/flake.nix
