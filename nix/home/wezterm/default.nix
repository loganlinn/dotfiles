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
  fennelLuaBootstrap = ''
    -- Workaround: https://github.com/wez/wezterm/issues/5323#issuecomment-2095316976
    debug = {traceback = function() end}
    package.path = "${fennel}/share/lua/${fennel.lua.luaversion}/?.lua;" .. package.path
  '';
in
{
  programs.wezterm = {
    enable = mkDefault true;
    enableBashIntegration = mkDefault true;
    enableZshIntegration = mkDefault true;
    extraConfig = ''
      local config = require('dotfiles.wezterm')

      config.front_end = config.front_end or "WebGpu" -- https://github.com/wez/wezterm/issues/6005
      config.color_scheme = config.color_scheme or "Dracula (Official)"
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

      return config
    '';
  };

  xdg.configFile = {
    "wezterm/dotfiles".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/wezterm/dotfiles";
    "wezterm/colors/dracula".source = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "wezterm";
      rev = "0db525a46b5242ee15fd4a52f887e172fbde8e51";
      hash = "sha256-sEoXqIAqedezT7cA0HhPsIfu1bWWxJS5+cd7nwK/Aps=";
    };
    "wezterm/.luarc.json".text = builtins.toJSON {
      workspace.library = [
        (pkgs.fetchzip {
          url = "https://github.com/justinsgithub/wezterm-types/archive/1518752906ba3fac0060d9efab6e4d3ec15d4b5a.zip";
          sha256 = "sha256-dSxsrgrapUezQIGhNp/Ikc0kISfIdrlUZxUBdsLVe3A=";
        })
      ];
    };
    "wezterm/.gitignore".text = ".luarc.json";
  };
}
