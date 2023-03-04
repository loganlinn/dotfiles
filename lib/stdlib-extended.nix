# Just a convenience function that returns the given Nixpkgs standard
# library extended with my library.
#
# Idea borrowed from <home-manager/modules/lib/stdlib-extended.nix>

stdlib:

let
  mkMyLib = import ./.;
in
stdlib.extend (self: super: {
  my = mkMyLib { lib = self; };
})
