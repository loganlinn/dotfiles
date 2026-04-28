{
  lib,
  inputs',
  ...
}:
{
  services.hyprpaper = {
    enable = lib.mkDefault true;
    package = inputs'.hyprpaper.packages.hyprpaper;
    settings = {
      splash = false;
      ipc = "on";
      # Override these to set a wallpaper:
      # services.hyprpaper.settings.preload = ["path/to/wallpaper.png"];
      # services.hyprpaper.settings.wallpaper = [",path/to/wallpaper.png"];
    };
  };
}
