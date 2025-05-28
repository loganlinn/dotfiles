{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    mouse = true;
    shortcut = "f";
    terminal = "screen-256color";
  };

  programs.fzf.tmux.enableShellIntegration = true;

  # Fix IntelliJ terminal issue where every keypress was accompanied by 'tmux' or 'tmux;'
  programs.zsh.initContent = ''
    [[ $TERMINAL_EMULATOR -ne "JetBrains-JediTerm" ]] || unset TMUX
  '';

  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/tmux/tmux.conf";
}
