{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dracula = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "wezterm";
    rev = "0db525a46b5242ee15fd4a52f887e172fbde8e51";
    hash = "sha256-sEoXqIAqedezT7cA0HhPsIfu1bWWxJS5+cd7nwK/Aps=";
  };
in
{
  programs.wezterm = {
    enable = mkDefault true;
    enableBashIntegration = mkDefault true;
    enableZshIntegration = mkDefault true;
    extraConfig = ''
      wezterm.add_to_config_reload_watch_list(wezterm.config_dir)

      local config = wezterm.config_builder()

      -- https://github.com/wez/wezterm/issues/6005
      config.front_end = "WebGpu"

      config.color_scheme_dirs = { '${dracula}' }
      config.color_scheme = "Dracula"

      return require('config')(config) or config
    '';
  };

  xdg.configFile."wezterm/config.lua".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/wezterm/config.lua";
}
