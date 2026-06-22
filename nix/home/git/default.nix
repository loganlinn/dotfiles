{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  privateConfigFile = "${config.xdg.configHome}/git/config.local";
  allowedSignersFile = "${pkgs.writeText "allowed_signers" ''
    ${config.my.email} ${config.my.pubkeys.ssh.ed25519}
  ''}";
  gpg-ssh-program = (
    if pkgs.stdenv.isDarwin
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else "op-ssh-sign"
  );
  gitTopLevelFunctions = ''
    _git_top_level_usage() {
      local usage_name=$1 target_name=$2

      printf '%s\n' \
        "Usage:" \
        "  $usage_name [--cd PATH] [-x|--exec COMMAND [ARG ...] [; ...]]" \
        "" \
        "Target:" \
        "  $target_name top-level git worktree" \
        "" \
        "Options:" \
        "  --cd PATH       Use PATH relative to the target top-level. Default: ." \
        "  -x, --exec CMD  Run CMD from the target directory. Default: pwd" \
        "  -h, --help      Show this help." \
        "" \
        "Notes:" \
        "  After -x/--exec, all following positional arguments belong to CMD." \
        "  Use ';' to end a command and continue parsing options or another -x." \
        "" \
        "Examples:" \
        "  $usage_name" \
        "  $usage_name --cd src -x git status --short" \
        "  $usage_name -x pwd ';' --cd \"\$(git rev-parse --show-prefix)\" -x git status --short"
    }

    _git_top_level_root_worktree() {
      local line

      while IFS= read -r line; do
        case "$line" in
          worktree\ *)
            printf '%s\n' "''${line#worktree }"
            return 0
            ;;
        esac
      done < <(git worktree list --porcelain)

      return 1
    }

    _git_top_level_run() {
      if [[ -n ''${ZSH_VERSION-} ]]; then
        emulate -L zsh
      fi

      local kind=$1 usage_name=$2 target_name=$3
      shift 3

      local cd_path=. top target arg exit_status
      local sentinel=$'\037'
      local -a exec_args=()

      while (( $# )); do
        case "$1" in
          -h|--help)
            _git_top_level_usage "$usage_name" "$target_name"
            return 0
            ;;
          --cd)
            shift
            if (( ! $# )); then
              printf '%s\n' "$usage_name: --cd requires a path" >&2
              return 2
            fi
            cd_path=$1
            shift
            ;;
          --cd=*)
            cd_path=''${1#--cd=}
            shift
            ;;
          -x|--exec)
            shift
            local added=0

            while (( $# )); do
              if [[ $1 == ';' ]]; then
                if (( ! added )); then
                  printf '%s\n' "$usage_name: -x requires a command" >&2
                  return 2
                fi
                exec_args+=("$sentinel")
                shift
                break
              fi

              exec_args+=("$1")
              added=1
              shift
            done

            if (( ! added )); then
              printf '%s\n' "$usage_name: -x requires a command" >&2
              return 2
            fi
            ;;
          *)
            printf '%s\n' "$usage_name: unexpected argument: $1" >&2
            printf '%s\n' "$usage_name: use -x/--exec before command arguments" >&2
            return 2
            ;;
        esac
      done

      if [[ $cd_path == /* ]]; then
        printf '%s\n' "$usage_name: --cd expects a relative path: $cd_path" >&2
        return 2
      fi

      case "$kind" in
        current)
          top=$(git rev-parse --show-toplevel) || return $?
          ;;
        root)
          top=$(_git_top_level_root_worktree) || return $?
          ;;
        *)
          printf '%s\n' "$usage_name: invalid target kind: $kind" >&2
          return 2
          ;;
      esac

      target=$top
      if [[ -n $cd_path && $cd_path != "." ]]; then
        target="$top/$cd_path"
      fi

      cd -- "$target" || return $?

      if (( ''${#exec_args[@]} == 0 )); then
        exec_args=(pwd)
      fi

      local -a cmd=()
      for arg in "''${exec_args[@]}"; do
        if [[ $arg == "$sentinel" ]]; then
          if (( ''${#cmd[@]} )); then
            "''${cmd[@]}"
            exit_status=$?
            (( exit_status == 0 )) || return $exit_status
            cmd=()
          fi
          continue
        fi

        cmd+=("$arg")
      done

      if (( ''${#cmd[@]} )); then
        "''${cmd[@]}"
      fi
    }

    gtl() {
      _git_top_level_run current gtl current "$@"
    }

    grt() {
      _git_top_level_run root grt root "$@"
    }
  '';
in {
  imports = [
    ../shell
    ./gh.nix
    ./git-spice.nix
    ./ghq.nix
  ];

  # see: https://github.com/wfxr/forgit?tab=readme-ov-file#shell-aliases
  home.shellAliases = {
    gau = "git add -u";
    gap = "git add -p";
    gcm = ''git switch "$(git default-branch || echo main)"'';
    gco = "git checkout";
    gd = "git diff";
    gdc = "gd --cached";
    gdn = "git diff --name-only";
    gfa = "git fetch --all";
    gl = "git pull";
    glg = "git log --oneline --decorate";
    glr = "git pull --rebase";
    glrp = "git pull --rebase && git push";
    gp = "git push";
    grtp = ''cd -- "$(git worktree list --porcelain | grep -m1 "^worktree " | cut -d" " -f2- || echo .)/$(git rev-parse --show-prefix)" && pwd'';
    gw = "git show";
    gpwd = "git rev-parse --show-prefix";
    gpwdc = "git rev-parse --show-prefix | ${config.my.flakeDirectory}/bin/cb";
  };

  programs.bash.initExtra = gitTopLevelFunctions;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "arctic-fox"; # from included themes.gitconfig
      zero-style = "dim syntax auto";
      minus-style = "omit syntax auto";
      plus-style = "omit syntax auto";
      syntax-theme = "base16";

      navigate = 1; # seems to specifically want a number
      hyperlinks = true;
      line-numbers = true;
    };
  };

  programs.git = {
    enable = true;
    git-spice.enable = true;
    lfs.enable = true;
    package = mkDefault pkgs.gitFull; # gitk, ...
    ignores = [
      "*.local.md"
      "*.local.json"
      "*.local"
      ".vectimus/receipts"
      "___*"
    ];
    includes = let
      delta-themes = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dandavison/delta/ed09269ebace8aad765c57a2821502ebb8c11f11/themes.gitconfig";
        sha256 = "sha256-kPGzO4bzUXUAeG82UjRk621uL1faNOZfN4wNTc1oeN4=";
      };
    in [
      {path = ./include/gitalias.txt;}
      {path = delta-themes;}
      {path = privateConfigFile;}
    ];
    signing.key = mkDefault null; # let GnuPG decide
    settings = {
      advice.detachedHead = false;
      advice.skippedCherryPicks = false;
      advice.statusHints = false;
      alias.amend = "commit --amend";
      alias.branch-name = "rev-parse --abbrev-ref HEAD";
      alias.can = "commit --amend --no-edit";
      alias.cdup = "rev-parse --show-cdup";
      alias.config-private = "config --file ${privateConfigFile}";
      alias.fd = ''!${pkgs.fd}/bin/fd --search-path "$(git rev-parse --show-cdup)"'';
      alias.new = "commit --allow-empty-message -m ''";
      alias.prefix = "rev-parse --show-prefix";
      alias.rg = ''!f() { ${config.programs.ripgrep.package}/bin/rg "$@" "$(git rev-parse --show-cdup)"; }; f'';
      alias.toplevel = "rev-parse --show-toplevel";
      alias.touch = ''!git commit --amend --date="$(date -r)"'';
      alias.undo = "reset --soft HEAD~1";
      alias.wt = "worktree";
      blame.ignoreRevsFile = ".git-blame-ignore-revs"; # matches settings used by github
      branch.autoSetupRebase = "always";
      branch.sort = "-committerdate";
      checkout.defaultRemote = "origin";
      commit.gpgsign = mkDefault true;
      commit.verbose = true; # include diff in commit message editor
      diff.noprefix = true;
      fetch.all = true;
      fetch.prune = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = mkDefault allowedSignersFile;
      gpg.ssh.program = mkDefault gpg-ssh-program;
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "current";
      rebase.autosquash = true;
      stash.showIncludeUntracked = true;
      stash.showPatch = true;
      status.branch = true;
      status.displayCommentPrefix = false;
      status.short = true;
      status.showStash = true;
      user.email = config.my.email;
      user.name = "Logan Linn";
      user.signingkey = config.my.pubkeys.ssh.ed25519;
    };
  };

  programs.gpg.publicKeys = [
    {
      # source = pkgs.fetchurl { url = "https://github.com/web-flow.gpg"; };
      text = ''
        -----BEGIN PGP PUBLIC KEY BLOCK-----

        xsBNBFmUaEEBCACzXTDt6ZnyaVtueZASBzgnAmK13q9Urgch+sKYeIhdymjuMQta
        x15OklctmrZtqre5kwPUosG3/B2/ikuPYElcHgGPL4uL5Em6S5C/oozfkYzhwRrT
        SQzvYjsE4I34To4UdE9KA97wrQjGoz2Bx72WDLyWwctD3DKQtYeHXswXXtXwKfjQ
        7Fy4+Bf5IPh76dA8NJ6UtjjLIDlKqdxLW4atHe6xWFaJ+XdLUtsAroZcXBeWDCPa
        buXCDscJcLJRKZVc62gOZXXtPfoHqvUPp3nuLA4YjH9bphbrMWMf810Wxz9JTd3v
        yWgGqNY0zbBqeZoGv+TuExlRHT8ASGFS9SVDABEBAAHNNUdpdEh1YiAod2ViLWZs
        b3cgY29tbWl0IHNpZ25pbmcpIDxub3JlcGx5QGdpdGh1Yi5jb20+wsBiBBMBCAAW
        BQJZlGhBCRBK7hj4Ov3rIwIbAwIZAQAAmQEIACATWFmi2oxlBh3wAsySNCNV4IPf
        DDMeh6j80WT7cgoX7V7xqJOxrfrqPEthQ3hgHIm7b5MPQlUr2q+UPL22t/I+ESF6
        9b0QWLFSMJbMSk+BXkvSjH9q8jAO0986/pShPV5DU2sMxnx4LfLfHNhTzjXKokws
        +8ptJ8uhMNIDXfXuzkZHIxoXk3rNcjDN5c5X+sK8UBRH092BIJWCOfaQt7v7wig5
        4Ra28pM9GbHKXVNxmdLpCFyzvyMuCmINYYADsC848QQFFwnd4EQnupo6QvhEVx1O
        j7wDwvuH5dCrLuLwtwXaQh0onG4583p0LGms2Mf5F+Ick6o/4peOlBoZz48=
        =HXDP
        -----END PGP PUBLIC KEY BLOCK-----
      '';
    }
  ];

  programs.zsh = {
    initContent = ''
      ${gitTopLevelFunctions}

      zle -N git-widget
      zle -N git-open-widget
      bindkey '^X^G' git-widget
      bindkey '^Xg' git-widget

      copy-commit-msg() {
        local clip
        if command -v pbcopy >/dev/null; then clip=pbcopy
        elif command -v wl-copy >/dev/null; then clip=wl-copy
        elif command -v xclip >/dev/null; then clip="xclip -selection clipboard"
        else echo >&2 "no clipboard command found"; return 1
        fi
        git log -1 --pretty=%B | ''${=clip}
        echo "Commit message copied to clipboard"
      }

      gc() {
        emulate -L zsh
        local -a cmd=(git commit --verbose)
        # shorthand: bare arg without leading '-' is message or filename
        if [[ $# -eq 1 ]] && [[ ''${1-} != '-'* ]]; then
          if [[ -e $1 ]]; then
            cmd+=(-- "$1")
          else
            cmd+=(--message "$1")
          fi
        else
          cmd+=("$@")
        fi
        "''${cmd[@]}"
      }
    '';
    sessionVariables = {
      FORGIT_NO_ALIASES = "1";
      FORGIT_CHECKOUT_BRANCH_BRANCH_GIT_OPTS = "--sort=-committerdate";
    };
    shellAliases = {
      gadd = "forgit::add ";
      gattrs = "forgit::attributes ";
      gbco = "forgit::checkout::branch ";
      gblame = "forgit::blame ";
      gbrm = "forgit::branch::delete ";
      gcco = "forgit::checkout::commit ";
      gcherry = "forgit::cherry::pick ";
      gclean = "forgit::clean ";
      gdiff = "forgit::diff ";
      gfco = "forgit::checkout::file ";
      gfix = "forgit::fixup ";
      gfo = "git fetch origin";
      gignore = "forgit::ignore ";
      glog = "forgit::log ";
      grebase = "forgit::rebase ";
      greflog = "forgit::reflog ";
      greset = "forgit::reset::head ";
      grevert = "forgit::revert::commit ";
      greword = "forgit::reword ";
      gshow = "forgit::show ";
      gsp = "forgit::stash::push ";
      gsquash = "forgit::squash ";
      gsw = "forgit::stash::show ";
      gtag = "forgit::checkout::tag ";
    };

    antidote = {
      enable = mkDefault true;
      plugins = [
        "wfxr/forgit"
      ];
    };
  };
}
