{ inputs, withSystem, ... }:

{
  imports = [ inputs.flake-root.flakeModule ];

  flake.packages.x86_64-windows = withSystem "x86_64-linux" (
    ctx@{
      config,
      inputs',
      pkgs,
      ...
    }:
    {
      npiperelay = pkgs.callPackage ../nix/pkgs/npiperelay { };
    }
  );

}
