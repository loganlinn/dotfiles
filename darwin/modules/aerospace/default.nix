{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.aerospace;
in
{
  options.programs.aerospace = {
    enable = mkEnableOption "aerospace window manager";
    borders = {
      enable = mkEnableOption "JankyBorders";
    };
    configFile = mkOption {
      type = types.nullOr types.path;
      default = "${config.my.flakeDirectory}/config/aerospace/aerospace.toml";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.my.user.name} =
      { config, ... }:
      {
        xdg.configFile = optionalAttrs (cfg.configFile != null) {
          "aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink cfg.configFile;
        };
      };

    homebrew = {
      taps = [ "nikitabobko/tap" ] ++ optional cfg.borders.enable "FelixKratz/formulae";
      casks = [ "nikitabobko/tap/aerospace" ];
      brews = optional cfg.borders.enable "FelixKratz/formulae/borders";
    };

    environment.systemPath = [
      ./bin
    ];

    system.defaults = {
      # Move windows by holding ctrl+cmd and dragging any part of the window
      NSGlobalDomain.NSWindowShouldDragOnGesture = true;
      # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
      dock.expose-group-apps = true; # `true` means OFF
      # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
      spaces.spans-displays = true; # `true` means spaces span all displays; `false` means spaces are separate for each display
    };
  };
}
