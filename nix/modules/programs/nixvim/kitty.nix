{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nixvim = lib.mkIf config.programs.kitty.enable {
    plugins.kitty-scrollback = {
      enable = true;
    };
    # TODO activation script for generating kittens:
    # nvim --headless +'KittyScrollbackGenerateKittens'
  };
}
