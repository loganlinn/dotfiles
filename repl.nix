let
  flake = builtins.getFlake (toString ./.);
  nixpkgs = import <nixpkgs> { };
in
{ inherit flake; }
// flake
// builtins
// flake.inputs.nixpkgs
// flake.inputs.nixpkgs.lib
// flake.homeConfigurations
// flake.homeConfigurations."${builtins.getEnv "USER"}@${builtins.getEnv "HOSTNAME"}" or { }
// flake.darwinConfigurations
// flake.darwinConfigurations."${builtins.getEnv "USER"}@${builtins.getEnv "HOSTNAME"}" or { }
