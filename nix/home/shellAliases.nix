{
  conf,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  git = "${pkgs.git}/bin/git";
  home-manager = "${pkgs.home-manager}/bin/home-manager";
in {
  home.shellAliases = {
    "'..'" = "cd ..";
    "'...'" = "cd ...";

    "'?'" = "which";
    "'??'" = "which -a";

    l = "ls -lah";
    mkd = "mkdir -p";

    gc = "${git} commit -v";
    gca = "${git} commit -v -a";
    gco = "${git} switch";
    gcm = "${git} switch \"$(${git} default-branch || echo .)\"";
    gcob = "${git} switch -c";
    gcop = "${git} checkout -p";
    gd = "${git} diff --color";
    gdc = "${git} diff --color --cached";
    gfo = "${git} fetch origin";
    gl = "${git} pull";
    glr = "${git} pull --rebase";
    glrp = "glr && gp";
    gp = "${git} push -u";
    gpa = "${git} push all --all";
    gs = "${git} status -sb";
    gsrt = "${git} rev-parse --show-toplevel";
    gsw = "${git} stash show -p";
    gw = "${git} show";
    grt = ''cd -- "$(${git} rev-parse  --show-top-level || echo .)"'';

    nix-gc = "${pkgs.nix}/bin/nix-collect-garbage -d";
    nixq = "${pkgs.nix}/bin/nix-env -qaP";
    hm = "${home-manager}";

    switch =
      if pkgs.stdenv.isDarwin
      then "darwin-rebuild switch --impure --flake ~/.dotfiles#\${USER?}@\${HOST?}"
      else "${home-manager} switch --flake ~/.dotfiles#\${USER?}@\${HOST?}";

    k = "${pkgs.kubectl}/bin/kubectl";
    kctx = "${pkgs.kubectx}/bin/kubectx";
    kusers = "k config get-users";
    kdesc = "k describe";
    kdoc = "k describe";
    kinfo = "k cluster-info";
    kcfg = "k config view --raw";
    kk = "${pkgs.kustomize}/bin/kustomize";
    kkb = "kk build";

    s = "${pkgs.kitty}/bin/kitty +kitten ssh";

    bbr = "${pkgs.rlwrap}/bin/rlwrap bb";
  };
}
