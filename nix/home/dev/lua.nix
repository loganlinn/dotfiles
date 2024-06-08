{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (lua.withPackages (ps: [
      ps.luarocks
      # ps.tl
    ]))
    luaformatter
    # luarocks
    stylua
  ];
}
