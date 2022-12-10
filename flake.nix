{
  inputs = {
    #quokka.url = "nixpkgs/nixos-22.05";
    #racoon.url = "nixpkgs/nixos-22.11";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    # eww.url = "github:elkowar/eww";
    # nur.url = "github:nix-community/NUR";
    # nur.inputs.nixpkgs.follows = "nixpkgs";
    # statix.url = "github:nerdypepper/statix";
    # statix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    emacs,
    nix-doom-emacs,
    ...
  }: {
    homeConfigurations."logan@nijusan" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";

      modules = [
        nix-doom-emacs.hmModule
        ./nix/home/nijusan.nix
        ./nix/home/common.nix
        ./nix/home/dev.nix
        ./nix/home/pretty.nix
        {
          home.username = "logan";
          home.homeDirectory = "/home/logan";
          home.stateVersion = "22.11";
          programs.home-manager.enable = true;
          programs.doom-emacs = {
            enable = true;
            doomPrivateDir = ./config/doom;
          };
          services.emacs = {
            enable = true;
          };
        }
      ];
    };

    #homeConfigurations = {
    # "logan@framework" = home-manager.lib.homeManagerConfiguration {
    #   pkgs = nixpkgs.legacyPackages."x86_64-linux";
    #   modules = [
    #     ./nix/home/framework.nix
    #   ];
    # };

    nixosConfigurations.nijusan = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

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
