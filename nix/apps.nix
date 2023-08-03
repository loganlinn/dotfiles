{ pkgs, lib, ... }:

with lib;

let
  packages = pipe ./nix/apps [
    filesystem.listFilesRecursive
    (remove (hasPrefix "_"))
    (filter (hasSuffix ".nix"))
    (map (removeSuffix "default.nix"))
    (map (file: pkgs.callPackage file { }))
  ];

  mkApp = drv: {
    type = "app";
    program = getExe drv;
  };

  mkCheck = drv: { "app-${drv.name}" = drv; };
in
{
  apps = fold recursiveUpdate { } (map mkApp packages);
  checks = (fold recursiveUpdate { } (map mkCheck packages));
}
