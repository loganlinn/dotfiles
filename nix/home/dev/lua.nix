{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (lua.withPackages (ps: [
      ps.luarocks
      ps.readline
      ps.inspect
      ps.http
      ps.serpent
    ]))
    luaformatter
    # luarocks
    stylua
  ];
}
