{ config, lib, pkgs, ... }:

with lib;

{
  programs.git = {
    enable = true;
    package = pkgs.gitFull; # gitk, ...

    includes =
      [
        { path = "~/.config/git/config.local"; }
        { path = ./include/gitalias.txt; }
        {
          path = pkgs.writeText "patch-tech.gitconfig" ''
            [user]
            email = logan@patch.tech
          '';
          condition = "gitdir:~/src/github.com/patch-tech/**";
        }
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
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.program =
        if pkgs.stdenv.isDarwin then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "op-ssh-sign";
      user.signingkey = config.my.user.signingkey;
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
    signing.key = null; # let GnuPG decide
    userEmail = config.my.email;
    userName = "Logan Linn";
  };
}
