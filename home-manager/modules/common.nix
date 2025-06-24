{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkOption
    ;

  my = config.my;
  hm = config.home-manager.users.${my.user.name};
  fileType =
    (
      import inputs.home-manager
      + "/modules/lib/file-type.nix" {
        inherit (hm.home) homeDirectory;
        inherit lib pkgs;
      }
    ).fileType;
in
{
  options = {
    home = {
      file = mkOption {
        type = fileType "home.file" "" hm.home.homeDirectory;
        default = { };
      };

      configFile = mkOption {
        type = fileType "home.configFile" "" hm.xdg.configHome;
        default = { };
      };

      dataFile = mkOption {
        type = fileType "home.dataFile" "" hm.xdg.dataHome;
        default = { };
      };

      stateFile = mkOption {
        type = fileType "home.stateFile" "" hm.xdg.stateHome;
        default = { };
      };
    };
  };

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.users.${my.user.name} = {
      home.file = config.home.file;
      xdg.enable = true;
      xdg.configFile = config.home.configFile;
      xdg.dataFile = config.home.dataFile;
      xdg.stateFile = config.home.stateFile;
    };
  };
}
