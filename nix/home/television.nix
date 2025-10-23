{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  cfg = config.programs.television;
in
{
  xdg.configFile."television/cable".source =
    mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/television/cable";

  programs.television = {
    enable = lib.mkDefault true;
    enableZshIntegration = true;
    settings = {
      # keybindings = {
      #   quit = [ "ctrl-c" ];
      # };
    };
  };
}
