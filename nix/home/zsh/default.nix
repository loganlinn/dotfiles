{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with builtins;
with lib; let
  includeFile = file: ''

    #---------------------------------------------------------
    # ${file}
    #---------------------------------------------------------
    ${readFile file}
  '';
in {
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
    localVariables = {};
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
      flake = "nix flake";
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
      clcd = "mkdir -p ~/.claude && cd ~/.claude";
      clcfg = "editor ~/.claude/settings.json";
      clres = "claude --resume";
      dk = "docker";
      ddb-local = "aws dynamodb --endpoint-url http://localhost:${DYNAMODB_LOCAL_PORT: -8000}";
      ecr-login = "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 591791561455.dkr.ecr.us-east-2.amazonaws.com";
      gh = "env -u GITHUB_TOKEN gh";
      grtt = ''cd "$(git worktree list --porcelain | grep -m1 "^worktree " | cut -d" " -f2- || git rev-parse --show-toplevel || echo .)"'';
      gist = "gh gist";
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
      yolo = "claude --dangerously-skip-permissions";
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
      [[ ! -f ~/.zprofile.local ]] || source ~/.zprofile.local
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

        bindkey '^X^G' git-widget
        bindkey '^Xg' git-widget
        bindkey '^X^H^K' describe-key-briefly

        ${
          lib.optionalString
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

        function edit-zshrc-local {
          local a b f
          f=$HOME/.zshrc.local

          echo "editing $f"
          a=$(< "$f")
          b=$(vipe <<<"$a") || return 1
          if [[ "$a" == "$b" ]]; then
            echo "no changes detected"
            return 0
          fi

          if hash delta &>/dev/null; then
            diff -u <(printf '%s\n' "$a") <(printf '%s\n' "$b") | delta --paging=never
          else
            diff -u <(printf '%s\n' "$a") <(printf '%s\n' "$b")
          fi
          echo

          if ! zsh -n <<<"$b"; then
            echo >&2 "syntax error, aborting"
            return 1
          fi

          printf '%s\n' "$b" > "$f"
          echo "wrote: $f"

          if hash gh &>/dev/null; then
            local gistid=90b892b5069e95c2f893fab46177334a
            gh gist edit "$gistid" "$f"
            echo "updated: https://gist.github.com/$gistid"
          fi

          source "$f"
          echo "sourced: $f"

          echo 'done!'
        }

        alias zlocal='edit-zshrc-local'

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
