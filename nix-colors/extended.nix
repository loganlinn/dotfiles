{ nix-colors, nixpkgs ? import <nixpkgs> {}, ... }:

# with our colorSchemes configuration
nixpkgs.lib.recursiveUpdate nix-colors {
  colorSchemes = import ./schemes;
}
