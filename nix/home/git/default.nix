{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  privateConfigFile = "${config.xdg.configHome}/git/config.local";
  allowedSignersFile = "${pkgs.writeText "allowed_signers" ''
    ${config.my.email} ${config.my.pubkeys.ssh.ed25519}
  ''}";
  gpg-ssh-program = (
    if pkgs.stdenv.isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "op-ssh-sign"
  );
in
{
  imports = [
    ../shell
    ./gh.nix
    ./git-spice.nix
  ];

  home.packages = with pkgs; [
    delta
    difftastic
    gitu
    # git-absorb
  ];

  # see: https://github.com/wfxr/forgit?tab=readme-ov-file#shell-aliases
  home.shellAliases = {
    gc = "git commit -v";
    gca = "git commit -v -a";
    gcm = ''git switch "$(git default-branch || echo main)"'';
    gcob = "git switch -c";
    gcop = "git checkout -p";
    gd = "git diff --color";
    gdc = "gd --cached";
    gfo = "git fetch --all";
    glg = "git log --oneline --decorate";
    grt = ''cd -- "$(git rev-parse --show-toplevel || pwd)"''; # "goto root"
    gtl = ''git rev-parse --show-toplevel'';
    gw = "git show";
    st = "git status";
  };

  my.shellScripts = {
    gsw = ''
      declare -i n=''${1:-0}
      git stash show -p "stash@{$n}"
    '';
  };

  programs.git = {
    enable = true;
    git-spice.enable = true;
    package = mkDefault pkgs.gitFull; # gitk, ...
    includes = [
      { path = ./include/gitalias.txt; }
      {
        path = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/dandavison/delta/ed09269ebace8aad765c57a2821502ebb8c11f11/themes.gitconfig";
          sha256 = "sha256-kPGzO4bzUXUAeG82UjRk621uL1faNOZfN4wNTc1oeN4=";
        };
      }
      { path = privateConfigFile; }
    ];
    aliases = {
      branch-name = "rev-parse --abbrev-ref HEAD";
      config-private = "config --file ${privateConfigFile}";
      toplevel = "rev-parse --show-toplevel";
      cdup = "rev-parse --show-cdup";
      prefix = "rev-parse --show-prefix";
      fd = ''!${pkgs.fd}/bin/fd --search-path "$(git rev-parse --show-cdup)"'';
      rg = ''!f() { ${config.programs.ripgrep.package}/bin/rg "$@" "$(git rev-parse --show-cdup)"; }; f'';
      new = "commit --allow-empty-message -m ''";
      stash-search = ''
        !f() {
          if ! (( $# )); then
            set -- "$(${pkgs.gum}/bin/gum input --prompt="regex: " --placeholder=pattern)" || return "$?";
          fi;
          git stash list -i -G"$@";
        }; f
      '';
      stash-show-file = ''
        !f() {
          local stash=$1
          local file=$2
          if [[ -z $stash ]]; then
            stash=$(
              git stash list |
              ${pkgs.fzf}/bin/fzf --border-label '🥡 Stashes' --delimiter=: --preview "git show --color=always {1}" "$@" |
              cut -d: -f1
            ) || return $?;
          fi;
          if [[ -z $file ]]; then
            file=$(
              git ls-files "$(git rev-parse --show-toplevel)" |
              ${pkgs.fzf}/bin/fzf  --color=always --preview="git diff $stash^! -- {1}"
            ) || return $?;
          fi;
          git diff "$stash"^! -- "$file";
        }; f'';
      # stash-checkout-file = ''
      #   !f() {
      #     local idx=''${1-0};
      #     local file=''${2?main};
      #     if [[ $idx =  ]]
      #     shift;
      #     git checkout "stash@{$idx}" -- "$@";
      #   }; f'';

      # worktree
      wt = "worktree";
      wtm = "worktree-main";
      wtl = "worktree-linked";
      wtr = ''
        !${pkgs.writeShellScriptBin "git-worktree-rm" ''
          for p in $(git worktree list --porcelain | ${pkgs.gawk}/bin/awk '(NR>1) && /^worktree / { print $2 }' | ${pkgs.fzf}/bin/fzf -0 -m); do
            ${pkgs.gum}/bin/gum confirm "git worktree remove $p" &&
            git worktree remove --force "$p"
          done
        ''}
      '';
      wtx = "!${./worktree-shell.sh}";
      worktree-linked = "!git worktree list --porcelain | grep -E 'worktree ' | cut -d' ' -f2 | tail -n +2";
      worktree-main = "!git worktree list --porcelain | head -n1 | cut -d' ' -f2";
      # amend = "commit --amend --reuse-message HEAD";
      touch = ''!git commit --amend --date="$(date -r)"'';
      undo = "reset --soft HEAD~1";
      default-branch = ''
        !f() {
          git rev-parse --git-dir &>/dev/null || return $?;
          for a in heads remotes; do
            for b in origin upstream; do
              for c in main trunk master; do
                if git show-ref --quiet --verify "refs/$a/$b/$c"; then
                  printf %q "$c";
                  return;
                fi;
              done;
            done;
          done;
          gh api /repos/{owner}/{repo} --jq '.default_branch'
        }; f'';
    };

    lfs.enable = true;

    difftastic = {
      enable = false;
      background = "dark";
    };

    delta = {
      enable = true;
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
    extraConfig = {
      advice.detachedHead = false;
      advice.skippedCherryPicks = false;
      advice.statusHints = false;
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
      user.signingkey = mkDefault config.my.pubkeys.ssh.ed25519;
    };
    # hooks
    signing.key = mkDefault null; # let GnuPG decide
    userEmail = mkDefault config.my.email;
    userName = mkDefault "Logan Linn";
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
}
