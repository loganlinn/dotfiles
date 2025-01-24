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
  options = import ./options.nix { inherit config pkgs lib; };

  config = mkIf cfg.enable {
    homebrew = {
      taps = [ "nikitabobko/tap" ] ++ optional cfg.borders.enable "FelixKratz/formulae";
      casks = [ "nikitabobko/tap/aerospace" ];
      brews = optional cfg.borders.enable "FelixKratz/formulae/borders";
    };

    home-manager.users.${config.my.user.name} = {
      xdg.configFile."aerospace/aerospace.toml" = {
        source = (pkgs.formats.toml { }).generate "aerospace.toml" cfg.settings;
        onChange = ''${config.homebrew.brewPrefix}/aerospace reload-config'';
      };
      home.packages = cfg.extraPackages;
    };

    system.defaults = {
      # Move windows by holding ctrl+cmd and dragging any part of the window
      NSGlobalDomain.NSWindowShouldDragOnGesture = true;
      # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
      dock.expose-group-apps = true; # `true` means OFF
      # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
      spaces.spans-displays = true; # `true` means OFF
    };
  };
}
