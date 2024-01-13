{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./gh.nix
  ];

  programs.git = {
    enable = true;
    package = mkDefault pkgs.gitFull; # gitk, ...
    includes = [
      { path = "~/.config/git/config.local"; }
      { path = ./include/gitalias.txt; }
    ];
    aliases = {
      wt = "worktree";
      wtm = "worktree-main";
      wtl = "worktree-linked";
      wtr = ''!f() {
        for p in $(git worktree list --porcelain | ${pkgs.gawk}/bin/awk '(NR>1) && /^worktree / { print $2 }' | ${pkgs.fzf}/bin/fzf -0 -m); do
          ${pkgs.gum}/bin/gum confirm "git worktree remove $p" &&
          git worktree remove --force "$p"
        done
      }; f'';
      wtx = "!${./worktree-run.sh}";
      worktree-linked = "!git worktree list --porcelain | grep -E 'worktree ' | cut -d' ' -f2 | tail -n +2";
      worktree-main = "!git worktree list --porcelain | head -n1 | cut -d' ' -f2";
      amend = "commit --amend --reuse-message HEAD";
      touch = ''!git commit --amend --date="$(date -r)"'';
      undo = "reset --soft HEAD~1";
      stack = "!gt stack";
      upstack = "!gt upstack";
      us = "!gt upstack";
      downstack = "!gt downstack";
      ds = "!gt downstack";
      b = "!gt branch";
      l = "!gt log";
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
    delta = {
      enable = true;
      options = {
        hunk-header-style = "omit";
        theme = "zenburn";
        navigate = "true";
        side-by-side = "true";
        line-numbers = "true";
      };
    };
    extraConfig = {
      advice.detachedHead = false;
      advice.skippedCherryPicks = false;
      advice.statusHints = false;
      branch.autoSetupRebase = "always";
      branch.sort = "-committerdate";
      color.ui = true;
      commit.verbose = true; # include diff in commit message editor
      commit.gpgsign = mkDefault true;
      gpg.format = "ssh";
      gpg.ssh.program =
        mkDefault (if pkgs.stdenv.isDarwin then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "op-ssh-sign");
      gpg.ssh.allowedSignersFile = mkDefault "${pkgs.writeText "allowed_signers" ''
        ${config.my.email} ${config.my.user.signingkey}
      ''}";
      user.signingkey = mkDefault config.my.user.signingkey;
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "tracking";
      rebase.autosquash = true;
      stash.showPatch = true;
      stash.showIncludeUntracked = true;
      credential."imap.fastmail.com".helper =
        let
          helper = pkgs.writeShellScript "fastmail-imap-credetnial-helper" ''
            echo "password=op://Personal/cbosmbv3b7kbtk2g7eleeackiq/credential" | op inject
          '';
        in
        "${helper}";
    };
    # hooks
    signing.key = mkDefault null; # let GnuPG decide
    userEmail = mkDefault config.my.email;
    userName = mkDefault "Logan Linn";
  };

  home.packages = with pkgs; [
    delta
  ];

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
