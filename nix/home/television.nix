{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  cableDir = "${config.my.flakeDirectory}/config/television/cable";
in {
  xdg.configFile =
    mapAttrs'
    (name: _:
      nameValuePair
      "television/cable/${name}"
      {
        source = mkOutOfStoreSymlink "${cableDir}/${name}";
      })
    (builtins.readDir cableDir);

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
