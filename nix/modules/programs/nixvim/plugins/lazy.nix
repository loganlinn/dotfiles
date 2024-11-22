{ config, ... }:
{
  programs.nixvim = {
    plugins.lazy = {
      enable = config.programs.nixvim.plugins.lazy.plugins != [ ];
      plugins = [ ];
    };
  };
}
