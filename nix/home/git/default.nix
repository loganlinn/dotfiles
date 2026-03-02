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

  # see: https://github.com/wfxr/forgit?tab=readme-ov-file#shell-aliases
  home.shellAliases = {
    gmain = ''git switch "$(git default-branch || echo main)"'';
    gtop = ''cd -- "$(git rev-parse --show-toplevel || echo .)" && pwd'';
    groot = ''cd -- "$(git worktree list --porcelain | grep -m1 "^worktree " | cut -d" " -f2- || echo .)" && pwd'';
    gco = "git switch -c";
    gd = "git diff";
    gdc = "gd --cached";
    gdn = "git diff --name-only";
    gfa = "git fetch --all";
    glg = "git log --oneline --decorate";
    gp = "git push";
    gtl = ''git rev-parse --show-toplevel'';
    gw = "git show";
  };

  home.packages = with pkgs; [
    # gitu
  ];

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
    includes =
      let
        delta-themes = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/dandavison/delta/ed09269ebace8aad765c57a2821502ebb8c11f11/themes.gitconfig";
          sha256 = "sha256-kPGzO4bzUXUAeG82UjRk621uL1faNOZfN4wNTc1oeN4=";
        };
      in
      [
        { path = ./include/gitalias.txt; }
        { path = delta-themes; }
        { path = privateConfigFile; }
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
      branch.autoSetupRebase = "always";
      branch.sort = "-committerdate";
      checkout.defaultRemote = "origin";
      commit.gpgsign = mkDefault true;
      commit.verbose = true; # include diff in commit message editor
      core.excludesfile = "${config.xdg.configHome}/git/ignore";
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
      gc() {
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
      glog = "forgit::log ";
      greflog = "forgit::reflog ";
      gdiff = "forgit::diff ";
      gshow = "forgit::show ";
      gadd = "forgit::add ";
      greset = "forgit::reset::head ";
      gignore = "forgit::ignore ";
      gattrs = "forgit::attributes ";
      gfco = "forgit::checkout::file ";
      gbco = "forgit::checkout::branch ";
      gbrm = "forgit::branch::delete ";
      gtag = "forgit::checkout::tag ";
      gcco = "forgit::checkout::commit ";
      grevert = "forgit::revert::commit ";
      gclean = "forgit::clean ";
      gsw = "forgit::stash::show ";
      gsp = "forgit::stash::push ";
      gcherry = "forgit::cherry::pick ";
      grebase = "forgit::rebase ";
      gblame = "forgit::blame ";
      gfix = "forgit::fixup ";
      gsquash = "forgit::squash ";
      greword = "forgit::reword ";
    };

    antidote = {
      enable = mkDefault true;
      plugins = [
        "wfxr/forgit"
      ];
    };
  };
}
