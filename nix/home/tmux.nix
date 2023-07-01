{ config, lib, pkgs, ... }:

{
  programs.tmux = {
    enable = tue;
    sensibleOnTop = true;
    mouse = true;
    shortcut = "f";
    terminal = "screen-256color";
  };

  programs.fzf.tmux.enableShellIntegration = true;

  # Fix IntelliJ terminal issue where every keypress was accompanied by 'tmux' or 'tmux;'
  programs.zsh.initExtra = ''
    [[ $TERMINAL_EMULATOR -ne "JetBrains-JediTerm" ]] || unset TMUX
  '';
}
