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
    grt = ''cd -- "$(git rev-parse --show-top-level || echo .)"'';

    nix-gc = "nix-collect-garbage -d";
    nixq = "nix-env -qaP";
    hm = "home-manager";

    k = "kubectl";
    kctx = "kubectx";
    kk = "kustomize";
    kkb = "${kk} build";

    s = "kitty +kitten ssh";

    bb = "rlwrap bb";
  };
}
