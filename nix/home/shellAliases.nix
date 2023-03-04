{ conf, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin;
in
{
  home.shellAliases = rec {
    "'..'" = "cd ..";
    "'...'" = "cd ...";
    "'?'" = "which";
    "'??'" = "which -a";
    l = "ls -lah";
    mkd = "mkdir -p";

    gc = "git commit -v";
    gca = "git commit -v -a";
    gco = "git switch";
    gcm = ''git switch "$(git default-branch || echo .)"'';
    gcob = "git switch -c";
    gcop = "git checkout -p";
    gd = "git diff --color";
    gdc = "git diff --color --cached";
    gfo = "git fetch origin";
    gl = "git pull";
    glr = "git pull --rebase";
    glrp = "${glr} && ${gp}";
    gp = "git push -u";
    gpa = "git push all --all";
    gs = "git status -sb";
    gsrt = "git rev-parse --show-toplevel";
    gsw = "git stash show --patch";
    gw = "git show";
    gtl = "git rev-parse --show-toplevel";
    gtlr = "git rev-parse --show-cdup"; # "toplevel relative"
    gwd = "git rev-parse --show-prefix"; # "git working directory"
    grt = ''cd -- "$(gtl || pwd)"''; # "goto root"

    nix-gc = "nix-collect-garbage -d";
    nixq = "nix-env -qaP";
    nixpkgs = "nix repl --expr 'let pkgs = import <nixpkgs> {}; in builtins // pkgs.lib // { inherit pkgs; }'";

    k = "kubectl";
    kctx = "kubectx";
    kk = "kustomize";
    kkb = "${kk} build";

    s = "kitty +kitten ssh";

    bb = "rlwrap bb";

    now = "date +%s";
    today = "date -Idate";

  };
}
