{
  self',
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.age-op;
in
{
  options.programs.age-op = {
    enable = mkEnableOption "age-op";
    package = mkOption {
      type = types.package;
      default = self'.packages.age-op;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
