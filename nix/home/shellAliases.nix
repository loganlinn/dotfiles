{ conf, lib, pkgs, ... }: {
  home.shellAliases = let
    inherit (lib) getExe;
    inherit (pkgs.stdenv.targetPlatform) isDarwin;
    git = getExe pkgs.git;
    kitty = getExe pkgs.kitty;
  in rec {
    "'..'" = "cd ..";
    "'...'" = "cd ...";
    "'?'" = "which | xargs readlink";
    "'??'" = "which -a | xargs readlink";
    l = "ls -lah";
    mkd = "mkdir -p";

    gc = "${git} commit -v";
    gca = "${git} commit -v -a";
    gco = "${git} switch";
    gcm = ''${git} switch "$(${git} default-branch || echo .)"'';
    gcob = "${git} switch -c";
    gcop = "${git} checkout -p";
    gd = "${git} diff --color";
    gdc = "${git} diff --color --cached";
    gfo = "${git} fetch origin";
    gl = "${git} pull";
    glr = "${git} pull --rebase";
    glrp = "${glr} && ${gp}";
    gp = "${git} push -u";
    gpa = "${git} push all --all";
    gs = "${git} status -sb";
    gsrt = "${git} rev-parse --show-toplevel";
    gsw = "${git} stash show --patch";
    gw = "${git} show";
    grt = ''cd -- "$(${git} rev-parse --show-top-level || echo .)"'';

    nix-gc = "nix-collect-garbage -d";
    nixq = "nix-env -qaP";
    hm = getExe pkgs.home-manager;

    k = getExe pkgs.kubectl;
    kctx = getExe pkgs.kubectx;
    kk = getExe pkgs.kustomize;
    kkb = "${kk} build";

    s = "${kitty} +kitten ssh";

    bb = "${getExe pkgs.rlwrap} ${getExe pkgs.babashka}";
  };
}
