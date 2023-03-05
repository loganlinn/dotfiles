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
    shellAliases = {
      sudo = "sudo ";
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
      sync = "$HOME/Sync";
      dots = "$HOME/.dotfiles";
      src = "$HOME/src";
      gh = "$HOME/src/github.com";
      pat = "$HOME/src/github.com/patch-tech/patch";
      be = "$HOME/src/github.com/patch-tech/patch/backend";
    };

    initExtraFirst = ''
      # Stop TRAMP (in Emacs) from hanging or term/shell from echoing back commands
      if [[ $TERM == dumb || -n $INSIDE_EMACS ]]; then
        unsetopt zle prompt_cr prompt_subst
        whence -w precmd >/dev/null && unfunction precmd
        whence -w preexec >/dev/null && unfunction preexec
        PS1='$ '
      fi
    '';

    initExtraBeforeCompInit = ''
      ${readFile ./editor.zsh}
    '';

    initExtra = ''
      setopt EXTENDED_GLOB        # Use extended globbing syntax.
      setopt IGNOREEOF            # Do not exit on end-of-file <C-d>
      setopt EQUALS               # Expansion of =command expands into full pathname of command
      setopt LONG_LIST_JOBS       # List jobs in the long format by default.
      setopt AUTO_RESUME          # Attempt to resume existing job before creating a new process.
      setopt NOTIFY               # Report status of background jobs immediately.
      unsetopt BG_NICE            # Don't run all background jobs at a lower priority.
      unsetopt HUP                # Don't kill jobs on shell exit.
      setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
      setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
      setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

      DIRSTACKSIZE=9

      # Ensure XON signals are disabled to allow Ctrl-Q/Ctrl-S to be bound.
      stty -ixon

      ${optionalString config.programs.fzf.enable
        ''
        source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

        gco() {
          local selected
          if selected=$(_fzf_git_each_ref --no-multi); then
            [[ -n $selected ]] && git checkout "$selected"
          fi
        }
        ''}

      ${readFile ./clipboard.zsh}

      ${readFile ./funcs.zsh}

      ${optionalString config.programs.kitty.enable
        "kitty + complete setup zsh | source /dev/stdin"}

      ${optionalString config.programs.tmux.enable
        # Fix IntelliJ terminal issue where every keypress was accompanied by 'tmux' or 'tmux;'
        ''[[ $TERMINAL_EMULATOR -ne "JetBrains-JediTerm" ]] || unset TMUX''}

      source ${./../../../bin/src-get}

      [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
    '';
  };
}
