{ inputs, self, lib, ... }:

{
  perSystem = ctx@{ self', inputs', system, pkgs, ...}: {
    legacyPackages = lib.optionalAttrs (ctx.system == "x86_64-linux") {
      homeConfigurations."logan@nijusan" = self.lib.dotfiles.mkHomeConfiguration ctx {
        imports = [
          self.homeModules.common
          ./nijusan.nix
        ];
      };
    };
  };
}
