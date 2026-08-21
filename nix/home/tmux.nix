{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
  };

  programs.fzf.tmux.enableShellIntegration = true;

  programs.zsh = {
    dirHashes."tmux" = "${config.xdg.configHome}/tmux";
  };

  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/tmux/tmux.conf";
}
