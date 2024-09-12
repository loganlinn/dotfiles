# USAGE: nix repl repl.nix --argstr HOST
{
  flakeref ? (toString ./..),
  name ? "${builtins.getEnv "USER"}@${import ../lib/currentHostname.nix}",
  system ? builtins.currentSystem,
}:
let
  flake = builtins.getFlake flakeref;
  cfg = flake.legacyPackages.${system}.darwinConfigurations.${name};
in
flake // cfg
