{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../modules/programs/nixvim
  ];
  xdg.configFile = {
    "nvim/lua".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim/lua";
    "nvim/plugin/local-plugins.lua".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim/plugin/local-plugins.lua";
    "nvim_dotfiles".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim";
  };
}
