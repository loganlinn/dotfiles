# [`nix registry`](https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-registry)
{
  self,
  inputs,
  config,
  lib,
  ...
}:

with lib;

let cfg = config.my.nix-registry; in
{
  options.my.nix-registry = {
    fromInputs = mkOption {
      type = types.listOf types.str;
      default = [
        "nixpkgs"
        "home-manager"
      ];
    };
  };

  config = {
    nix.registry =
      let
        inputFlakes = (getAttrs cfg.fromInputs inputs);
        extraFlakes = {
          dotfiles = self;
        };
        allFlakes = attrsets.unionOfDisjoint inputFlakes extraFlakes;
      in
        mapAttrs (name: flake: { inherit flake; }) allFlakes;
  };
}
