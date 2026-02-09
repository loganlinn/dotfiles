{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with builtins;
with lib;
let
  includeFile = file: ''

    #---------------------------------------------------------
    # ${file}
    #---------------------------------------------------------
    ${readFile file}
  '';
in
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
    zprof.enable = false;
    enableCompletion = true;
    defaultKeymap = "emacs";
    sessionVariables = config.home.sessionVariables;
    localVariables = { };
    autosuggestion.enable = true;
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
      aliasez = ''alias | fzf'';
      commands = ''${pkgs.coreutils}/bin/basename -a "''${commands[@]}" | sort | uniq'';
      commandz = ''commands | fzf'';

      show-path = ''print -rl -- $path | nl -ba | less'';
      show-fpath = ''print -rl -- $fpath | nl -ba | less'';
      show-aliases = ''print -rl -- $aliases | nl -ba | less'';
      show-source = ''zsh -o SOURCE_TRACE -l -c true'';

      path_prepend = ''[[ -d $1 ]] && path=($1 ''${path:#$1})'';
      path_append = ''[[ -d $1 ]] && path=(''${path:#$1} $1)'';

      showkey = ''bindkey -L | ${pkgs.bat}/bin/bat'';
      sudo = "sudo ";
      "?" = "whence -fs";
      asu = "aws-sso-util";
      asuL = "aws-sso-util logout";
      asul = "aws-sso-util login";
      b = "bun";
      br = "bun run";
      ch = "noglob clickhouse";

      cl = "claude";
      cla = "claude --allow-dangerously-skip-permissions";
      clcd = "mkdir -p ~/.claude && cd ~/.claude";
      clcfg = "editor ~/.claude/settings.json";
      clres = "claude --resume";
      yolo = "claude --dangerously-skip-permissions";
      sonnet = "claude --model sonnet";
      opus = "claude --model opus";
      haiku = "claude --model haiku";
      sonnet1m = "claude --model 'sonnet[1m]'";
      opusplan = "claude --model opusplan";

      d = "docker";
      ddb-local = "aws dynamodb --endpoint-url http://localhost:$${DYNAMODB_LOCAL_PORT: -8000}";
      ecr-login = "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 591791561455.dkr.ecr.us-east-2.amazonaws.com";
      gh = "env -u GITHUB_TOKEN gh";
      grtt = ''cd "$(git worktree list --porcelain | grep -m1 "^worktree " | cut -d" " -f2- || git rev-parse --show-toplevel || echo .)"'';
      gist = "gh gist";
      hg = "kitten hyperlinked-grep";
      k = "kubectl";
      kk = "kustomize";
      li = "linearis";
      lil = "linearis issues list";
      m = "mise";
      mr = "mise run";
      mx = "mise exec";
      nix = "noglob nix";
      pbc = "pbcopy";
      pbp = "pbpaste";
      zcp = "zmv -C";
    };
    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
      # https://github.com/sharkdp/bat/blob/master/README.md#highlighting---help-messages
      "-?" = ''--help 2>&1 | ${pkgs.bat}/bin/bat --language=help --style=plain'';
      # "-h" = ''-h 2>&1 | ${pkgs.bat}/bin/bat --language=help --style=plain --paging=never'';
    };
    dirHashes = mergeAttrsList [
      (mapAttrs (_: input: "${input}") inputs) # ~nixpkgs, ~home-manager, etc
      (filterAttrs (_: value: value != null) config.my.userDirs)
      rec {
        cache = ''''${XDG_CACHE_HOME:-$HOME/.cache}'';
        cfg = ''''${XDG_CONFIG_HOME:-$HOME/.config}'';
        cl = ''''$HOME/.claude'';
        data = ''''${XDG_DATA_HOME:-$HOME/.local/share}'';
        dl = ''''${XDG_DOWNLOADS_DIR:-$HOME/Downloads}'';
        doom = ''''${DOOMDIR:-${cfg}/doom}'';
        dot = ''''${DOTFILES_DIR:-$HOME/.dotfiles}'';
        emacs = ''''${EMACSDIR:-${cfg}/emacs}'';
        gh = ''${src}/github.com'';
        kitty = ''''${XDG_CONFIG_HOME:-$HOME/.config}/kitty'';
        nvim = ''${cfg}/nvim''${NVIM_APPNAME:+"_$NVIM_APPNAME"}'';
        src = ''''${SRC_HOME:-$HOME/src}'';
        state = ''''${XDG_DATA_HOME:-$HOME/.local/state}'';
        tv = ''''${XDG_CONFIG_HOME:-$HOME/.config}/television'';
        wez = ''''${WEZTERM_CONFIG_DIR:-${cfg}/wezterm}'';
      }
      (optionalAttrs pkgs.stdenv.targetPlatform.isDarwin {
        app = ''$HOME/Library/Application Support'';
        launch = ''$HOME/Library/LaunchAgents'';
        logs = ''$HOME/Library/Logs'';
        lib = ''$HOME/Library'';
        prefs = ''$HOME/Library/Preferences'';
        chrome = ''$HOME/Library/Application Support/Google/Chrome'';
        ff = ''$HOME/Library/Application Support/Firefox'';
      })
    ];
    envExtra = ''
      # if [[ -n "$CLAUDECODE" ]]; then
      #   eval "$(direnv hook zsh)"
      # fi

      [[ ! -f ~/.zshenv.local ]] || source ~/.zshenv.local

      # Ensure path arrays do not contain duplicates.
      typeset -gU path fpath

      ${optionalString pkgs.stdenv.targetPlatform.isDarwin ''
        # Prevent /etc/zshrc_Apple_Terminal from running some unnecessary code for session persistence.
        export SHELL_SESSIONS_DISABLE=1
      ''}
    '';
    profileExtra = ''
      unalias run-help
      autoload -Uz run-help
      autoload -Uz zmv

      [[ ! -f ~/.zprofile.local ]] || source ~/.zprofile.local
    '';
    initExtraBeforeCompInit = ''
      typeset -U fpath # Ensure fpath does not contain duplicates.
      fpath+=("$HOME/.local/share/zsh/site-functions")
    '';
    completionInit = ''
      # Ensure XON signals are disabled to allow Ctrl-Q/Ctrl-S to be bound.
      stty -ixon
    '';
    initContent = mkMerge [
      (mkBefore ''
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
      '')
      # Preempt things like fzf integration: https://github.com/nix-community/home-manager/blob/f21d9167782c086a33ad53e2311854a8f13c281e/modules/programs/fzf.nix#L223
      (mkOrder 900 (includeFile ./line-editor.zsh)) # FIXME: declutter this flile
      # (mkOrder 900 (includeFile ./clipcopy.zsh))
      # (mkAfter (includeFile ./nixpkgs.zsh))
      # (mkAfter (includeFile ./wezterm.zsh))
      (mkAfter (includeFile ./sudo-prompt.zsh))
      (mkAfter ''
        ##########################################################

        function +nixpkgs () {
          command nix shell "''${@/#/nixpkgs#}"
        }

        function @nixpkgs () {
          command nix run "''${@/#/nixpkgs#}"
        }

        ${lib.optionalString config.programs.bat.enable ''
          ##########################################################

          # eval "$(batman --export-env)"

          # Disabled due to: 'ps: time: requires entitlement'
          # eval "$(batpipe)"

          function help  { "$@" --help 2>&1 | bat --plain --language=help; }

        ''}
        ##########################################################

        fpath=("${config.my.flakeDirectory}/config/zsh/functions" $fpath)
        autoload -U $fpath[1]/*(.:t)

        zle -N git-widget
        zle -N git-open-widget
        cle-widget() { BUFFER="cle"; zle accept-line }
        zle -N cle-widget

        bindkey '^X^G' git-widget
        bindkey '^Xg' git-widget
        bindkey '^X^X' cle-widget
        bindkey '^X^H^K' describe-key-briefly

        ${lib.optionalString
          (
            config.programs.television.enable
            && config.programs.television.enableZshIntegration
            && config.programs.fzf.enableZshIntegration
          )
          ''
            ##########################################################

            # Prefer fzf's history search over television's
            bindkey -M emacs '^R' fzf-history-widget
            bindkey -M vicmd '^R' fzf-history-widget
            bindkey -M viins '^R' fzf-history-widget

          ''
        }
      '')
      (mkAfter ''
        ##########################################################

        [ "$TERM" = "xterm-kitty" ] && alias ssh="command kitty +kitten ssh"

        ##########################################################

        function zshrc_audit_local() {
          emulate -L zsh
          setopt typeset_silent

          local tmp1 tmp2
          tmp1=$(mktemp) || return 1
          tmp2=$(mktemp) || { rm -f $tmp1; return 1; }

          # Snapshot state BEFORE
          {
            print -r -- "## vars"; typeset -pm
            print -r -- "## aliases"; alias
            print -r -- "## functions"; functions | sed 's/ .*$//'
            print -r -- "## options"; setopt
            print -r -- "## path"; print -rl -- $path
          } >| $tmp1

          # Source local
          source ~/.zshrc.local

          # Snapshot state AFTER
          {
            print -r -- "## vars"; typeset -pm
            print -r -- "## aliases"; alias
            print -r -- "## functions"; functions | sed 's/ .*$//'
            print -r -- "## options"; setopt
            print -r -- "## path"; print -rl -- $path
          } >| $tmp2

          # Show what changed
          diff -u $tmp1 $tmp2 | less

          rm -f $tmp1 $tmp2
        }

        ########################################################## 

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
