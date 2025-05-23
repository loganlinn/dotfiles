# USAGE: nix repl repl.nix --argstr name USER@HOST
let
  inherit (import ../lib {}) flakeRoot currentHostname;
in
  {
    flakeref ? flakeRoot,
    name ? "${builtins.getEnv "USER"}@${currentHostname}",
    system ? builtins.currentSystem,
  }: let
    flake = builtins.getFlake flakeref;
    cfg = flake.legacyPackages.${system}.homeConfigurations.${name};
  in
    flake // cfg
