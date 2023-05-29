{ self, withSystem, inputs, ... }:

{
  flake.nixosModules = {
    # ...
  };

  flake.nixosConfigurations.nijusan = withSystem "x86_64-linux"
    (ctx@{ config, inputs', ... }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self inputs inputs';
          inherit (config) packages;
        };
        modules = [
          ./options.nix
          # inputs.home-manager.nixosModules.home-manager
          # inputs.sops-nix.nixosModules.sops
          ./nijusan/configuration.nix
          { nixpkgs.config.allowUnfree = true; }
          {
            environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
            nix.nixPath = ["nixpkgs=/etc/nix/inputs/nixpkgs"];
          }
          # config.nixosModules.my-module
        ];
      });
}
