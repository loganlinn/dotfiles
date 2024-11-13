{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = {
    home.packages = with pkgs; [
      lua-language-server
      (lua.withPackages (
        ps: with ps; [
          luarocks
          readline
          inspect
          http
          serpent
          fennel
        ]
      ))
      luaformatter
      # luarocks
      stylua
      fnlfmt
      fennel-ls
    ];
  };
}
