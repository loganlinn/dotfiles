{
  inputs = {
    #quokka.url = "nixpkgs/nixos-22.05";
    #racoon.url = "nixpkgs/nixos-22.11";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    # nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    # nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    # eww.url = "github:elkowar/eww";
    # nur.url = "github:nix-community/NUR";
    # nur.inputs.nixpkgs.follows = "nixpkgs";
    # statix.url = "github:nerdypepper/statix";
    # statix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    emacs,
    # nix-doom-emacs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations = {
      "logan@framework" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./nix/home/framework.nix
        ];
      };

      # "logan@nijusan" = home-manager.lib.homeManagerConfiguration {
      #   modules = [
      #     nix-doom-emacs.hmModule
      #     ./nix/home/common.nix
      #     ./nix/home/emacs.nix
      #   ];
      #   extraSpecialArgs = {inherit nixpkgs unstable emacs doom-emacs;};
      # };

      # nixosConfigurations.nijusan = nixpkgs-racoon.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     ./nix/hardware/nijusan.nix
      #   ];
      # };

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
  };
}
# Acknowledgements
# - https://gitlab.com/rprospero/dotfiles/-/blob/master/flake.nix

