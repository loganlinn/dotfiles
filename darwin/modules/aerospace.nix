{ config, lib, pkgs, ... }:

let

  configFormat = pkgs.formats.toml {};


in
{
  homebrew.casks = [
    "nikitabobko/tap/aerospace"
  ];

  # Move windows by holding ctrl+cmd and dragging any part of the window
  system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = lib.mkDefault true;

  # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
  system.defaults.dock.expose-group-by-app = lib.mkDefault true; # `true` means OFF

  # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
  system.defaults.spaces.spans-displays = lib.mkDefault true; # `true` means OFF
}
