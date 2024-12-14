{ inputs, config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../../modules/programs/nixvim
  ];
  xdg.configFile = {
    "nvim/lua".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim/lua";
  };
}
