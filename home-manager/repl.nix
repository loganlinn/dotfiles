# USAGE: nix repl repl.nix --argstr name USER@HOST
{
  flakeref ? (toString ./..),
  name ? "${builtins.getEnv "USER"}@${import ../lib/currentHostname.nix}",
  system ? builtins.currentSystem,
}:
let
  flake = builtins.getFlake flakeref;
  cfg = flake.legacyPackages.${system}.homeConfigurations.${name};
in
flake // cfg
