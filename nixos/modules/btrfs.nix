{ options, config, lib, pkgs, ... }:

let
  cfg = config.modules.btrfs;

  isBtrfs = fs: fs.fsType == "btrfs";

  btrfsFileSystems = lib.filterAttrs (p: fs: isBtrfs fs) config.fileSystems;

in
{
  options.modules.btrfs = with lib; {
    enable = mkOption {
      name = "btrfs module";
      default = mkDefault (btrfsFileSystems != {});
      type = types.bool;
    };


  };

  config = {
    services.btrbk = {
      enable = cfg.enable;
      extraPackages = [ pkgs.lz4 ];
      instances = {

      };
    };

  };
}
