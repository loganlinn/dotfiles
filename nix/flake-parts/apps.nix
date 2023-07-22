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

# { lib, ... }:

# with lib;

# let

#   files = filesystem.listFilesRecursive ../apps;

#   options = {
#     packages = mkOption {
#       type = with types; listOf package;
#       readOnly = true;
#       default = drvs;
#     };
#   };
# in
# {
#   perSystem = { pkgs, config, ... }:
#     let
#       drvs = pkgs: forEach files (file: pkgs.callPackage file { });
#     in
#     {
#       apps = listToAttrs
#         (forEach drvs (drv: {
#           inherit (drv) name;
#           value = {
#             type = "app";
#             program = getExe drv;
#           };
#         }));

#       checks = listToAttrs
#         (forEach drvs (drv: {
#           name = "app-${drv.name}";
#           value = drv;
#         }));
#     };
# }
