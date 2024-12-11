{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  cfg = config.programs.hammerspoon;
in
{
  options = {
    programs.hammerspoon = {
      enable = mkEnableOption "hammerspoon";
    };
  };
  config = mkIf cfg.enable {
    home.file.".hammerspoon".source =
      mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/hammerspoon";
  };
}
