{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    defaultKeymap = "emacs";
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
    sessionVariables = lib.mkOptionDefault config.home.sessionVariables;
    dirHashes = {
      cfg = config.xdg.configHome;
      dls = config.xdg.userDirs.download;
      docs = config.xdg.userDirs.documents;
      pics= config.xdg.userDirs.pictures;
      music = config.xdg.userDirs.music;
      vids = config.xdg.userDirs.videos;
      dot = "$HOME/.dotfiles";
      src = "$HOME/src";
    };
    initExtra = ''
      # Allow kill word and moving forward/backword by word to behave like bash (e.g. stop at / chars)
      autoload -U select-word-style
      select-word-style bash

      # Make color constants available
      autoload -U colors
      colors

      ${import ./confirm-exit.nix { inherit lib pkgs; }}

      ${builtins.readFile ./keybindings.zsh}

      ${builtins.readFile ./clipboard.zsh}

      ${optionalString
        config.programs.kitty.enable
        "kitty + complete setup zsh | source /dev/stdin"}

      # Fix IntelliJ terminal issue where every keypress was accompanied by 'tmux' or 'tmux;'
      if [[ "$TERMINAL_EMULATOR" -eq "JetBrains-JediTerm" ]]; then
        unset TMUX
      fi

      source ${./../../../bin/src-get}

      [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
    '';
  };
}
