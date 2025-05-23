{
  config,
  lib,
  pkgs,
  ...
}:
with builtins; {
  programs.urxvt = {
    enable = true;
    iso14755 = true; # support for viewing and entering unicode characters
    keybindings = {
      "Shift-Control-C" = "eval:selection_to_clipboard";
      "Shift-Control-V" = "eval:paste_clipboard";
    };
    transparent = true;
    shading = 100; # Darken (0 .. 99) or lighten (101 .. 200) the transparent background.
    scroll = {
      scrollOnKeystroke = true;
      scrollOnOutput = false;
      keepPosition = true;
      lines = 10000;
    };
    fonts = let
      cfg = config.my.fonts.terminal;
    in [
      "xft:${cfg.name}:size=${
        if cfg.size == null
        then 12
        else (toString cfg.size)
      }:antialias=true"
      "xft:Material Design Icons:size=14:minspace=false"
    ];
  };
  home.packages = with pkgs; [
    material-design-icons
  ];
}
