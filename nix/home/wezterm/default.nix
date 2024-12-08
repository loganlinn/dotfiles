{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  fennel = pkgs.lua54Packages.fennel;
  fennel-lua = ''
    --{{{fennel
    debug = { traceback = function() end } -- workaround for https://github.com/wez/wezterm/issues/5323#issuecomment-2095316976
    package.path = "${fennel}/share/lua/${fennel.lua.luaversion}/?.lua;" .. package.path
    --}}}fennel
  '';
  dracula = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "wezterm";
    rev = "0db525a46b5242ee15fd4a52f887e172fbde8e51";
    hash = "sha256-sEoXqIAqedezT7cA0HhPsIfu1bWWxJS5+cd7nwK/Aps=";
  };
in
{
  programs.wezterm = {
    # package = inputs.wezterm.packages.${pkgs.system}.default;
    enable = mkDefault true;
    enableBashIntegration = mkDefault true;
    enableZshIntegration = mkDefault true;
    extraConfig = ''
      ${fennel-lua}
      local config = require('dotfiles.wezterm')
      config.front_end = config.front_end or "WebGpu" -- https://github.com/wez/wezterm/issues/6005
      config.color_scheme = config.color_scheme or "Dracula (Official)"
      return config
    '';
  };
  xdg.configFile = {
    "wezterm/dotfiles".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/wezterm/dotfiles";
    "wezterm/colors/dracula".source = dracula;
  };
}
