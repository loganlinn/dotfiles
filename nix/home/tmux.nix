{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    mouse = true;
    shortcut = "f";
    terminal = "screen-256color";
  };

  programs.fzf.tmux.enableShellIntegration = true;

  programs.zsh = {
    dirHashes."tmux" = "${config.xdg.configHome}/tmux";
  };

  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/tmux/tmux.conf";
}
