{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

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
      commands = ''${pkgs.coreutils}/bin/basename -a "''${commands[@]}" | sort | uniq'';
      commandz = ''commands | fzf'';
      aliasez = ''alias | fzf'';
    };

    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };

    sessionVariables = mkOptionDefault config.home.sessionVariables;

    dirHashes =
      let
        cfg = "$${XDG_CONFIG_HOME:-$HOME/.config}";
      in
      mergeAttrsList [
        (mapAttrs (name: input: "${input}") inputs)
        (rec {
          inherit cfg;
          cache = "$${XDG_CACHE_HOME:-$HOME/.cache}";
          data = "$${XDG_DATA_HOME:-$HOME/.local/share}";
          state = "$${XDG_DATA_HOME:-$HOME/.local/state}";
          bin = "$HOME/.local/bin";

          dot = "$${DOTFILES_DIR:-$HOME/.dotfiles}";
          src = "$${SRC_HOME:-$HOME/src}";
          gh = "${src}/github.com";
          doom = "$${DOOMDIR:-${cfg}/doom}";
          emacs = "$${EMACSDIR:-${cfg}/emacs}";

          gamma = "${gh}/gamma-app/gamma";
        })
        (optionalAttrs config.xdg.enable {
          dl = config.xdg.userDirs.download;
          docs = config.xdg.userDirs.documents;
          pics = config.xdg.userDirs.pictures;
          vids = config.xdg.userDirs.videos;
        })
        (optionalAttrs config.programs.wezterm.enable {
          wez = "$${WEZTERM_CONFIG_DIR:-${cfg}/wezterm}";
        })
        (optionalAttrs config.programs.kitty.enable {
          kitty = "${cfg}/kitty";
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
      [[ ! -f "$XDG_CONFIG_DIR/zsh/initExtraFirst.zsh" ]] || source "$XDG_CONFIG_DIR/zsh/initExtraFirst.zsh"

      # Stop TRAMP (in Emacs) from hanging or term/shell from echoing back commands
      if [[ $TERM == dumb || -n $INSIDE_EMACS ]]; then
        unsetopt zle prompt_cr prompt_subst
        whence -w precmd >/dev/null && unfunction precmd
        whence -w preexec >/dev/null && unfunction preexec
        PS1='$ '
      fi
    '';

    initExtraBeforeCompInit = ''
      [[ ! -f "$XDG_CONFIG_DIR/zsh/initExtraBeforeCompInit.zsh" ]] || source "$XDG_CONFIG_DIR/zsh/initExtraBeforeCompInit.zsh"

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

    initExtra =
      let
        functionsDir = toString ./functions;
      in
      ''
        [[ ! -f "$XDG_CONFIG_DIR/zsh/initExtra.zsh" ]] || source "$XDG_CONFIG_DIR/zsh/initExtra.zsh"

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

        fpath+=("${functionsDir}" "$${XDG_DATA_HOME:-$$HOME/.local/share}/zsh/functions")

        ${concatLines (map (name: "autoload -Uz ${name}") (attrNames (builtins.readDir functionsDir)))}

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

  xdg.configFile =
    let
      inherit (config.lib.file) mkOutOfStoreSymlink;
      cwd = "${config.home.homeDirectory}/.dotfiles/nix/home/zsh";
    in
    {
      "zsh/initFirst.zsh".source = mkOutOfStoreSymlink "${cwd}/initFirst.zsh";
      "zsh/initExtraBeforeCompInit.zsh".source = mkOutOfStoreSymlink "${cwd}/initExtraBeforeCompInit.zsh";
      "zsh/initExtra.zsh".source = mkOutOfStoreSymlink "${cwd}/initExtra.zsh";
    };
}
