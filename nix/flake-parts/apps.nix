{ lib, ... }:
with lib; {
  perSystem = { pkgs, config, ... }:
    pipe ../apps [
      filesystem.listFilesRecursive
      (map (file: pkgs.callPackage file { }))
      (map (drv: {
        apps.${drv.name} = {
          type = "app";
          program = getExe drv;
        };
        checks."app-${drv.name}" = drv;
      }))
      (fold recursiveUpdate { })
    ];
}
