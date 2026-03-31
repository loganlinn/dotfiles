{
  config,
  lib,
  ...
}:
with lib;
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile."ccstatusline/settings.json".source =
    mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/ccstatusline/settings.json";
}
