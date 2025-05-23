{
  nix-colors,
  nixpkgs,
  ...
}:
# add custom colorSchemes, etc to nix-colors
nixpkgs.lib.recursiveUpdate nix-colors (import ./.)
