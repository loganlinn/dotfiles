{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.nixvim = {
    plugins.kitty-scrollback = {
      enable = true;
    };
    # TODO activation script for generating kittens:
    # nvim --headless +'KittyScrollbackGenerateKittens'
  };
}
