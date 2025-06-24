{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
  };

  config = {
    homebrew = {
      casks = [
        "sf-symbols"
      ];
    };

    home-manager.users.${config.my.user.name} =
      { config, ... }:
      {
        xdg.configFile."sketchybar/sketchybarrc".source =
          config.lib.file.mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/sketchybar/sketchybarrc";
      };

    fonts.packages = with pkgs; [
      hack-font
    ];
  };
}
