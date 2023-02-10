{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    jetbrains.idea-community
  ];

  # Better font rendering
  home.sessionVariables = {
    "_JAVA_OPTIONS" = "-Dawt.useSystemAAFontSettings=lcd";
  };

  # home.files.".ideavimrc" = ./ideavimrc;
}
