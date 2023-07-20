{ lib, ... }:

with lib;

{
  perSystem = { pkgs, options, config, ... }: {
    options = {
      my.packages = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };

    };

    config = {
      my.packages = pipe ../pkgs [
        filesystem.listFilesRecursive
        (filter filesystem.pathIsRegularFile)
        (filter (hasSuffix ".nix"))
        (remove (hasPrefix "."))
        (map (file: pkgs.callPackage file { }))
        # (map (drv: {
        #   my.packages.${drv.name} = drv;
        # }))
        # (fold recursiveUpdate { })
      ];
    };
  };

}
