{ inputs, config, ... }:
{
  # xdg.configFile."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
  # home.sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/inputs/nixpkgs:$NIX_PATH";
}
