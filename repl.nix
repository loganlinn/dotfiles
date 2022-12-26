let flake = builtins.getFlake (toString ./.);
in
{
  inherit flake;
}
// flake
// flake.inputs
// builtins
// flake.inputs.nixpkgs.lib
// flake.homeConfigurations
// flake.homeConfigurations."${builtins.getEnv "USER"}@${builtins.getEnv "HOSTNAME"}" or { }
// flake.darwinConfigurations
// flake.darwinConfigurations."${builtins.getEnv "USER"}@${builtins.getEnv "HOSTNAME"}" or { }
