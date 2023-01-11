{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    jetbrains.idea-community
  ];

  # home.files.".ideavimrc" = ./ideavimrc;
}
