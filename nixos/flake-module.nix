{ self, inputs, ... }:

let

  inherit (inputs) nixpkgs home-manager sops-nix;
  inherit (nixpkgs) lib;

  nixosSystem = args:
    (lib.makeOverridable lib.nixosSystem)
      (lib.recursiveUpdate args {
        modules = args.modules ++ [
          {
            config.nixpkgs.pkgs = lib.mkDefault args.pkgs;
            config.nixpkgs.localSystem = lib.mkDefault args.pkgs.stdenv.hostPlatform;
          }
        ];
      });

  defaultModules = [
    # # make flake inputs accessiable in NixOS
    # {
    #   _module.args.self = self;
    #   _module.args.inputs = self.inputs;
    # }
  ];

in
{
  flake.nixosConfigurations = {
    nijusan = nixosSystem {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      specialArgs = { inherit self inputs; };
      modules = defaultModules ++ [
        # home-manager.nixosModules.home-manager
        # sops-nix.nixosModules.sops
        ./nijusan/configuration.nix
      ];
    };
  };

}
