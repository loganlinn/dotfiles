{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    defaultKeymap = "emacs";
    sessionVariables = {EDITOR = "vim";};
    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
      size = 100000;
      save = 100000;
    };
    shellGlobalAliases = {
      "..."="../..";
      "...."="../../..";
      "....."="../../../..";
      "......"="../../../../.." ;
    };
    dirHashes = {
      cfg = "$HOME/.config";
      nix = "$HOME/.dotfiles/nix";
      dot = "$HOME/.dotfiles";
      docs = "$HOME/Documents";
      dl = "$HOME/Downloads";
      src = "$HOME/src";
      gh = "$HOME/src/github.com";
      patch-tech = "$HOME/src/github.com/patch-tech";
      patch = "$HOME/src/github.com/patch-tech/patch";
    };
    initExtra = ''
      # Allow kill word and moving forward/backword by word to behave like bash (e.g. stop at / chars)
      autoload -U select-word-style
      select-word-style bash

      # Make color constants available
      autoload -U colors
      colors

      # Fix IntelliJ terminal issue where every keypress was accompanied by 'tmux' or 'tmux;'
      if [[ "$TERMINAL_EMULATOR" -eq "JetBrains-JediTerm" ]]; then
        unset TMUX
      fi

      if (( $+commands[kitty] )); then
        kitty + complete setup zsh | source /dev/stdin
      fi

      source ${./zsh/keybindings.zsh}
      source ${./zsh/clipboard.zsh}
      source ${./../../bin/src-get}

      [[ ! -f ~/zshrc.local ]] || source ~/.zshrc.local
    '';
  };
}
