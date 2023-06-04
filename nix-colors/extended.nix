{ nix-colors, nixpkgs ? import <nixpkgs> {}, ... }:

# extend with our colorSchemes, etc. this works for now...
nixpkgs.lib.recursiveUpdate nix-colors (import ./.)
