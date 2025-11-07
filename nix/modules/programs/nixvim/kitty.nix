{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.nixvim;
in {
  programs.nixvim = {
    plugins.kitty-scrollback = {
      enable = true;
    };
    # TODO activation script for generating kittens:
    # nvim --headless +'KittyScrollbackGenerateKittens'
  };
}
