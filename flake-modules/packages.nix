{ self, lib, ... }:

{
  perSystem = { config, pkgs, ... }: {

    # packages = let
    # pkgs' = pkgs.extend (lib.composeManyExtensions [ self.overlays.default ]);
    # in { inherit (pkgs') ; };

  };
}
