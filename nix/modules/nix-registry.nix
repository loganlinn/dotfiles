{ inputs, config, lib, ... }:

with lib;

let

  cfg = config.my.nix-registry;

in
{
  options.my.nix-registry = {
    fromInputs = mkOption {
      type = types.listOf types.str;
      default = [ "nixpkgs" "home-manager" ];
    };
  };

  config = {
    nix.registry = genAttrs cfg.fromInputs (name: {
      to = {
        type = "path";
        path = inputs."${name}";
      };
    });
  };
}
