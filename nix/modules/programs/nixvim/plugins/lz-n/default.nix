{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    extraPlugins = lib.mkIf cfg.plugins.lz-n.enable [ pkgs.vimPlugins.lzn-auto-require ];

    extraConfigLuaPost = lib.mkIf cfg.plugins.lz-n.enable (
      lib.mkOrder 5000 ''
        require('lzn-auto-require').enable()
      ''
    );

    plugins.lz-n.enable = true;
  };
}
