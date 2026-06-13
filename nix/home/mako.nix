{
  config,
  lib,
  pkgs,
  ...
}: let
  palette = config.colorScheme.palette;
in {
  services.mako = {
    enable = lib.mkDefault true;

    settings = {
      background-color = "#${palette.base00}";
      text-color = "#${palette.base05}";
      border-color = "#${palette.base04}";
      progress-color = "#${palette.base0D}";

      font = "${config.my.fonts.sans.name} 11";

      width = 420;
      height = 110;
      padding = "10,15";
      margin = "10";
      outer-margin = "20";
      border-size = 2;
      border-radius = 4;

      anchor = "top-right";
      layer = "overlay";

      default-timeout = 5000;
      ignore-timeout = false;
      max-visible = 5;
      sort = "-time";
      max-icon-size = 32;

      group-by = "app-name";

      actions = true;

      format = "<b>%s</b>\\n%b";
      markup = true;

      "[urgency=critical]" = {
        border-color = "#${palette.base08}";
        default-timeout = 0;
        layer = "overlay";
      };

      "[mode=do-not-disturb]" = {
        invisible = true;
      };

      "[mode=do-not-disturb app-name=notify-send]" = {
        invisible = false;
      };
    };
  };
}
