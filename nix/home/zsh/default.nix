{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with builtins;
with lib;
{
  imports = [
    ./options.nix
    ./plugins.nix
  ];

  home.packages = [
    (pkgs.writeScriptBin "zshi" (builtins.readFile ./bin/zshi))
  ];

  programs.zsh = {
    enable = true;

    enableCompletion = true;

    defaultKeymap = "emacs";

    dotDir = null; # ".config/zsh";

    sessionVariables = config.home.sessionVariables;

    localVariables = { };

    autosuggestion = {
      enable = true;
    };

    # syntaxHighlighting = {
    #   enable = true;
    #   # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
    #   highlighters = [
    #     "main"
    #     "brackets"
    #     "pattern"
    #     "regexp"
    #     "cursor"
    #     "root"
    #     "line"
    #   ];
    #   patterns = {
    #     # "rm -rf *" = "fg=white,bold,bg=red";
    #   };
    #   styles = {
    #     # comment = "fg=black,bold";
    #   };
    # };

    # zprof = {
    #   enable = true;
    # };

    # historySubstringSearch = {
    #   enable = true;
    # };

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
      # https://github.com/sharkdp/bat/blob/master/README.md#highlighting---help-messages
      "-?" = ''--help 2>&1 | ${pkgs.bat}/bin/bat --language=help --style=plain'';
      "-h" = ''-h 2>&1 | ${pkgs.bat}/bin/bat --language=help --style=plain --paging=never'';
    };

    dirHashes = mergeAttrsList [
      (mapAttrs (_: input: "${input}") inputs) # ~nixpkgs, ~home-manager, etc
      (filterAttrs (_: value: value != null) config.my.userDirs)
      rec {
        doom = ''''${DOOMDIR:-${cfg}/doom}'';
        dot = ''''${DOTFILES_DIR:-$HOME/.dotfiles}'';
        emacs = ''''${EMACSDIR:-${cfg}/emacs}'';
        gh = ''${src}/github.com'';
        nvim = ''${cfg}/nvim''${NVIM_APPNAME:+"_$NVIM_APPNAME"}'';
        src = ''''${SRC_HOME:-$HOME/src}'';
        wez = ''''${WEZTERM_CONFIG_DIR:-${cfg}/wezterm}'';
        # xdg
        cfg = ''''${XDG_CONFIG_HOME:-$HOME/.config}'';
        cache = ''''${XDG_CACHE_HOME:-$HOME/.cache}'';
        data = ''''${XDG_DATA_HOME:-$HOME/.local/share}'';
        dl = ''''${XDG_DOWNLOADS_DIR:-$HOME/Downloads}'';
        state = ''''${XDG_DATA_HOME:-$HOME/.local/state}'';
      }
      (optionalAttrs pkgs.stdenv.targetPlatform.isDarwin rec {
        apps = ''$HOME/Applications'';
        appdata = ''$HOME/Library/Application Support'';
        appscripts = ''$HOME/Library/Application Scripts'';
        launch = ''$HOME/Library/LaunchAgents'';
        logs = ''$HOME/Library/Logs'';
        lib = ''$HOME/Library/Logs'';
        prefs = ''$HOME/Library/Preferences'';
        chromedata = ''${appdata}/Google/Chrome'';
        firefoxdata = ''${appdata}/Firefox'';
      })
    ];

    envExtra = ''
      # Ensure path arrays do not contain duplicates.
      typeset -gU path fpath

      [[ ! -f ~/.zshenv.local ]] || source ~/.zshenv.local

      ${optionalString pkgs.stdenv.targetPlatform.isDarwin ''
        # Prevent /etc/zshrc_Apple_Terminal from running some unnecessary code for session persistence.
        export SHELL_SESSIONS_DISABLE=1
      ''}
    '';

    profileExtra = ''
      [[ ! -f ~/.zprofile.local ]] || source ~/.zprofile.local
    '';

    completionInit = ''
      # Ensure XON signals are disabled to allow Ctrl-Q/Ctrl-S to be bound.
      stty -ixon
    '';

    initContent = mkMerge [
      (mkBefore ''
        ${readFile ./line-editor.zsh}
      '')
      (mkAfter ''
        ## nixpkgs.zsh
        ${
          # readFile ./nixpkgs.zsh
          ""
        }

        ## wezterm.zsh
        ${
          # readFile ./wezterm.zsh
          ""
        }
        # wezterm::init

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

        fpath+=(
          "${config.my.flakeDirectory}/config/zsh/functions"
          "$XDG_DATA_HOME/zsh/functions"
        )


        bindkey "^[[1;3C" forward-word
        bindkey "^[[1;3D" backward-word
        bindkey -s '^G,' ' $(git rev-parse --show-cdup)\t'
        bindkey -s '^G.' ' "$(git rev-parse --show-prefix)"\t'
        bindkey -s '^G~' ' "$(git rev-parse --show-toplevel)"\t'
        bindkey -s '^G^G' ' git status^M' # ctrl-space (^M is accept line)
        bindkey -s '^G^S' ' git snapshot^M'
        bindkey -s '^G^_' ' "$(git rev-parse --show-toplevel)"\t' # i.e. C-g C-/
        bindkey -s '^G^c' ' gh pr checks^M'
        bindkey -s '^G^f' ' git fetch^M'
        bindkey -s '^G^g' ' git status^M'
        bindkey -s '^G^s' ' git snapshot^M'

        copy-line-to-clipboard() {
          printf '%s' "$EDITOR" | clipcopy
        }
        zle -N copy-to-clipboard
        bindkey '^Y' copy-to-clipboard

        if (( $+commands[bat] )); then
          alias d='batdiff'
          alias g='batgrep'
          eval "$(batman --export-env)"
          eval "$(batpipe)"
        fi

        [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
      '')
    ];

    loginExtra = ''
      [[ ! -f ~/.zlogin.local ]] || source ~/.zlogin.local
    '';

    logoutExtra = ''
      [[ ! -f ~/.zlogout.local ]] || source ~/.zlogout.local
    '';
  };
}
