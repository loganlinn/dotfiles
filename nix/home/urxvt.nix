{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    material-design-icons
    roboto
  ];
  programs.urxvt = {
    enable = true;
    iso14755 = false;
    keybindings = {
      "Shift-Control-C" = "eval:selection_to_clipboard";
      "Shift-Control-V" = "eval:paste_clipboard";
    };
  };
  xresources.properties = {
    "URxvt*boldFont" = [
      "xft:Roboto Mono:bold:size=12:antialias=true"
      "xft:Material Design Icons:size=14:minspace=false"
    ];
    "URxvt*italicFont" = [
      "xft:Roboto Mono:italic:size=12:antialias=true"
      "xft:Material Design Icons:size=14:minspace=false"
    ];
    "URxvt*boldItalicFont" = [
      "xft:Roboto Mono:bold:italic:size=12:antialias=true"
      "xft:Material Design Icons:size=14:minspace=false"
    ];
  };
}
