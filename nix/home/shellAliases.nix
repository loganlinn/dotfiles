{ config, lib, pkgs, ... }:

with pkgs; let
  dotfiles = "${home.path}/.dotfiles"
in {
  home.shellAliases = {
      "'?'" = "which";
      "'??'" = "which -a";
      ".." = "cd ..";
      "..." = "cd ...";

      et = "emacs -nw";

      gc = "${git} commit -v";
      gcob = "${git} checkout -b";
      gcop = "${git} checkout -p";
      gd = "${git} diff --color";
      gdc = "gd --cached";
      gl = "${git} pull";
      glr = "${git} pull --rebase";
      glrp = "glr && gp";
      gp = "${git} push -u";
      gpa = "${git} push all --all";
      gs = "${git} status -sb";
      gsrt = "${git} rev-parse --show-toplevel";
      gsw = "${git} stash show -p";
      gw = "${git} show";
      grt = ''cd -- "$(${git} rev-parse  --show-top-level || echo .)"''

      nix-gc = "nix-collect-garbage -d";
      nixq = "${nix}/bin/nix-env -qaP";
      home-switch = "${home-manager} switch --flake '${dotfiles}#\${USER?}@\${HOST?}'";
      hm-switch = "home-switch";
      hm = "${home-manager}";

      k = "${kubectl}";
      kctx = "${kubectx}";
      kusers = "k config get-users";
      kdesc = "k describe";
      kdoc = "k describe";
      kinfo = "k cluster-info";
      kcfg = "k config view --raw";
      kk = "${kustomize}";
      kkb = "kk build";

      bbr = "${rlwrap} bb";
    };
}
