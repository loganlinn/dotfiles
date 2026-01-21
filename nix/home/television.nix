{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile."television/cable".source =
    mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/television/cable";

  programs.television = {
    enable = mkDefault true;
    enableZshIntegration = true;
    settings = {
      # keybindings = {
      #   quit = [ "ctrl-c" ];
      # };
    };
  };
}
