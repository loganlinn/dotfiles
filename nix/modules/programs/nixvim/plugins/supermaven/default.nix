{ pkgs, ... }:
let
  configLua = builtins.readFile ./config.lua;
in
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.supermaven-nvim ];
    extraConfigLua = configLua;
  };
}
