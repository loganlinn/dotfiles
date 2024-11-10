{ pkgs, ... }:
let
  configLua = builtins.readFile ./config.lua;
in
{
  programs.nixvim = {
    extraPlugins = [pkgs.vimPlugins.supermaven-nvim];
    extraConfigLua = configLua;
    # plugins.lazy.enable = true;
    # plugins.lazy.plugins = [
    #   {
    #     enabled = true;
    #     event = "VeryLazy";
    #     config = configLua;
    #   }
    # ];
  };
}
