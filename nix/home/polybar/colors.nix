{ config, lib, pkgs, ... }:

with lib;

let
  colorScheme = mapAttrs (k: v: "#${v}")
    (lib.filterAttrs (k: _: hasPrefix "base" k)
      config.colorScheme.colors);

  colorAlias = name: "\${colors.${name}}";
in
{
  services.polybar.settings.colors = colorScheme // {

    background = colorAlias "base00";
    background-alt = colorAlias "base01";
    background-highlight = colorAlias "base03";

    foreground-dark = colorAlias "base04";
    foreground = colorAlias "base05";
    foreground-light = colorAlias "base06";

    highlight = colorAlias "base0A";
    selection = colorAlias "base02";

    primary = colorAlias "base0D";
    secondary = colorAlias "base0C";

    ok = colorAlias "base0B"; # i.e. diff added
    warn = colorAlias "base0E"; # i.e. diff changed
    alert = colorAlias "base08"; # i.e. diff deleted

    shade0 = "#1b2229";
    shade1 = "#1c1f24";
    shade2 = "#202328";
    shade3 = "#23272e";
    shade4 = "#3f444a";
    shade5 = "#5b6268";
    shade6 = "#73797e";
    shade7 = "#9ca0a4";
    shade8 = "#dfdfdf";

    transparent = "#00000000";

  };
}
