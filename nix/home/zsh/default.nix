{ lib
, config
, pkgs
, ...
}:

with builtins;
with lib;

let

  cfg = config.programs.zsh;

in
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
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };
    sessionVariables = lib.mkOptionDefault config.home.sessionVariables;
    dirHashes = {
      cfg = config.xdg.configHome;
      dls = config.xdg.userDirs.download;
      docs = config.xdg.userDirs.documents;
      pics = config.xdg.userDirs.pictures;
      music = config.xdg.userDirs.music;
      vids = config.xdg.userDirs.videos;
      dot = "$HOME/.dotfiles";
      src = "$HOME/src";
    };
    initExtra = ''
      ${readFile ./editor.zsh}

      # Make color constants available
      autoload -U colors
      colors

      ${import ./confirm-exit.nix { inherit lib pkgs; }}


      ${readFile ./clipboard.zsh}

      # Old habbits die hard
      (( ''${+commands[pbcopy]}  )) || alias pbcopy=clipcopy;
      (( ''${+commands[pbpaste]} )) || alias pbpaste=clippaste;

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
