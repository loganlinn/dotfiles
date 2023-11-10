{ config, lib, pkgs, ... }:

{
  programs.wezterm = {
    enable = lib.mkDefault true;
    extraConfig = ''
      wezterm.add_to_config_reload_watch_list(wezterm.config_dir)

      local config = wezterm.config_builder()

      local helpers = require 'helpers'

      helpers.apply_to_config(config)

      return config
    '';
  };

  xdg.configFile."wezterm/helpers.lua".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.dotfiles/config/wezterm/helpers.lua";

  xdg.configFile."wezterm/colors".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.dotfiles/config/wezterm/colors";
}
