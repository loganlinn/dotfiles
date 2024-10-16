{
  self,
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.aerospace;

  toml = pkgs.formats.toml { };

  configFile = toml.generate "aerospace.toml" cfg.settings;
in
{
  imports = [
    ./sketchybar.nix
    {
      # a.k.a JankyBorders
      homebrew.taps = [ "FelixKratz/formulae" ];
      homebrew.brews = [ "FelixKratz/formulae/borders" ];
    }
  ];

  options = {
    programs.aerospace = {
      enable = mkEnableOption "aerospace window manager";
      settings = mkOption {
        type = types.submodule {
          freeformType = toml.type;
        };
        default = {
          after-startup-command = [
            # use gh:FelixKratz/JankyBorders to higlight focus
            "exec-and-forget ${config.homebrew.brewPrefix}/borders"
          ];
        };
      };
    };
  };

  config = {
    homebrew = {
      taps = [ "nikitabobko/tap" ];
      casks = [ "nikitabobko/tap/aerospace" ];
    };

    home-manager.users.${config.my.user.name} = {
      xdg.configFile."aerospace/aerospace.toml".source = configFile;
    };

    # Move windows by holding ctrl+cmd and dragging any part of the window
    system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = lib.mkDefault true;

    # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
    system.defaults.dock.expose-group-by-app = lib.mkDefault true; # `true` means OFF

    # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
    system.defaults.spaces.spans-displays = lib.mkDefault true; # `true` means OFF

  };
}
