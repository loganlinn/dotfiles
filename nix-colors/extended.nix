{ nix-colors, nixpkgs ? import <nixpkgs> {}, ... }:

# add custom colorSchemes, etc to nix-colors
nixpkgs.lib.recursiveUpdate nix-colors (import ./.)
