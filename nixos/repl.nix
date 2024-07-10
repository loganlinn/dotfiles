# USAGE: nix repl repl.nix --argstr name HOST
{
  flakeref ? (toString ./..),
  name ? import ../lib/currentHostname.nix,
}:
let
  flake = builtins.getFlake flakeref;
  cfg = flake.nixosConfigurations.${name};
in
flake // cfg
