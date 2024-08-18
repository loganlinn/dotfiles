{ lib, config, pkgs, ... }:

with lib;

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
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
      commands =
        ''${pkgs.coreutils}/bin/basename -a "''${commands[@]}" | sort | uniq'';
    };

    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };

    sessionVariables = mkOptionDefault config.home.sessionVariables;

    dirHashes = mkMerge [
    {
      dotfiles = "$HOME/.dotfiles";
      dots = "$HOME/.dotfiles";
      src = "$HOME/src";
      gh = "$HOME/src/github.com";
      clj = "$HOME/src/github.com/clojure";
      pkgs = "$HOME/src/github.com/NixOS/nixpkgs";
      nixos = "$HOME/src/github.com/NixOS";
      nixpkgs = "$HOME/src/github.com/NixOS/nixpkgs";
      doom = "${config.xdg.configHome}/doom";
      doomd = "${config.xdg.configHome}/doom";
      emacs = "${config.xdg.configHome}/emacs";
      emacsd = "${config.xdg.configHome}/emacs";
      home-manager = "$HOME/src/github.com/nix-community/home-manager";
      hm = "$HOME/src/github.com/nix-community/home-manager";
    }
    (mkIf config.xdg.enable {
      cache = config.xdg.cacheHome;
      config = config.xdg.configHome;
      data = config.xdg.dataHome;
      state = config.xdg.stateHome;

      downloads = config.xdg.userDirs.download;
      dl = config.xdg.userDirs.download;

      documents = config.xdg.userDirs.documents;
      docs = config.xdg.userDirs.documents;
      doc = config.xdg.userDirs.documents;

      pic = config.xdg.userDirs.pictures;
      pics = config.xdg.userDirs.pictures;
      pictures = config.xdg.userDirs.pictures;

      music = config.xdg.userDirs.music;

      vids = config.xdg.userDirs.videos;

      # TODO: incorrect for WSL
      trash = "${config.xdg.dataHome}/Trash/files"; # https://specifications.freedesktop.org/trash-spec/trashspec-1.0.html
    })
    ];


    plugins = import ./plugins.nix { inherit config pkgs lib; };

    envExtra = ''
      [[ ! -f ~/.zshenv.local ]] || source ~/.zshenv.local
    '';

    profileExtra = ''
      [[ ! -f ~/.zprofile.local ]] || source ~/.zprofile.local
    '';

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
      ${readFile ./line-editor.zsh}

      # Ensure XON signals are disabled to allow Ctrl-Q/Ctrl-S to be bound.
      stty -ixon

      ${optionalString config.programs.fzf.enable ''
        source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

        gco() {
          if (( $# )); then
            git checkout "$@"
            return $?
          fi
          local selected
          if selected=$(_fzf_git_each_ref --no-multi); then
            [[ -n $selected ]] && git checkout "$selected"
          fi
        }
      ''}
    '';

    initExtra = let
      functionsDir = toString ./functions;
    in ''
      unsetopt EXTENDED_GLOB      # Don't use extended globbing syntax.
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

      fpath+=("${functionsDir}" "$HOME/.local/share/zsh/functions")
      ${concatLines
      (map (name: "autoload -Uz ${name}") (attrNames (builtins.readDir functionsDir)))}

      ${readFile ./clipboard.zsh}

      ${readFile ./funcs.zsh}

      ${readFile ./nixpkgs.zsh}

      [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
    '';

    loginExtra = ''
      [[ ! -f ~/.zlogin.local ]] || source ~/.zlogin.local
    '';

    logoutExtra = ''
      [[ ! -f ~/.zlogout.local ]] || source ~/.zlogout.local
    '';
  };
}
