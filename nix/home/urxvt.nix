{ config, lib, pkgs, ... }:

let
  inherit (builtins) toString;
  inherit (config.modules.theme) fonts;
in
{
  home.packages = with pkgs; [
    material-design-icons
    fonts.mono.package
  ];
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
    fonts = with config.modules.theme; [
      "xft:${fonts.mono.name}:size=${if fonts.mono.size == null then 12 else (toString fonts.mono.size)}:antialias=true"
      "xft:Material Design Icons:size=14:minspace=false"
    ];
  };
}
