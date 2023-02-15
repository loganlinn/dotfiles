{ inputs, ... }:

{
  perSystem = ctx@{ system, pkgs, ... }: {
    darwinConfigurations."logan@patchbook" = inputs.darwin.lib.darwinSystem {
      inherit inputs system pkgs;
      modules = [
        inputs.home-manager.darwinModules.home-manager
        ../nix/darwin/configuration.nix
        {
          home-manager.users.logan = import ../nix/home/darwin.nix;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };
  };
}
