{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  fennel = pkgs.lua54Packages.fennel;
in
{
  programs.wezterm = {
    enable = mkDefault true;
    enableBashIntegration = mkDefault true;
    enableZshIntegration = mkDefault true;
    extraConfig = ''
      package.path = "${fennel}/share/lua/${fennel.lua.luaversion}/?.lua;" .. package.path

      local config = require('dotfiles')

      config.front_end = config.front_end or "WebGpu" -- https://github.com/wez/wezterm/issues/6005

      config.color_scheme_dirs = config.color_scheme_dirs or {}
      table.insert(config.color_scheme_dirs,
        '${
          pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "wezterm";
            rev = "0db525a46b5242ee15fd4a52f887e172fbde8e51";
            hash = "sha256-sEoXqIAqedezT7cA0HhPsIfu1bWWxJS5+cd7nwK/Aps=";
          }
        }')

      config.color_scheme = config.color_scheme or "Dracula"

      return config
    '';
  };

  xdg.configFile = {
    "wezterm/dotfiles".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/wezterm/dotfiles";
  };
}
