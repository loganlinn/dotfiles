{ self, withSystem, inputs, ... }:

{
  flake.nixosModules = import ./modules;

  flake.nixosConfigurations.nijusan = withSystem "x86_64-linux"
    (system@{ config, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit (config) packages;
        };
        modules = [
          # inputs.home-manager.nixosModules.home-manager
          # inputs.sops-nix.nixosModules.sops
          ./nijusan/configuration.nix
          {
            options.my = system.options.my;
            config.my = system.config.my;
          }
          # ./options.nix
          # {
          #   environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
          #   nix.nixPath = ["nixpkgs=/etc/nix/inputs/nixpkgs"];
          # }
          # config.nixosModules.my-module
        ];
      });
}
