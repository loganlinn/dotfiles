{
  name, # i.e. scutil --get LocalHostName
  flakeref ? (toString ./..),
  system ? builtins.currentSystem,
}:
let
  flake = builtins.getFlake flakeref;
  cfg = flake.darwinConfigurations.${name};
in
flake // cfg
