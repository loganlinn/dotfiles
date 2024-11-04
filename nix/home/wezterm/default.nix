{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  programs.wezterm = {
    enable = mkDefault true;
    enableBashIntegration = mkDefault true;
    enableZshIntegration = mkDefault true;
    extraConfig = ''
      local config = wezterm.config_builder()

      config:set_strict_mode(true)

      config.front_end = "WebGpu" -- https://github.com/wez/wezterm/issues/6005

      config.color_scheme_dirs = {
        '${
          pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "wezterm";
            rev = "0db525a46b5242ee15fd4a52f887e172fbde8e51";
            hash = "sha256-sEoXqIAqedezT7cA0HhPsIfu1bWWxJS5+cd7nwK/Aps=";
          }
        }'
      }
      config.color_scheme = "Dracula"

      require('dotfiles').apply_to_config(config)

      return config
    '';
  };

  xdg.configFile = {
    "wezterm/dotfiles".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/wezterm";
  };
}
