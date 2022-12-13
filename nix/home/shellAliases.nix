{ pkgs, ... }:

{
  home.shellAliases = with pkgs;
    let gitBin = "${git}/bin/git";
    in {
      "'?'" = "which";
      "'??'" = "which -a";
      ".." = "cd ..";
      "..." = "cd ...";

      et = "emacs -nw";

      gc = "${gitBin} commit -v";
      gcob = "${gitBin} checkout -b";
      gcop = "${gitBin} checkout -p";
      gd = "${gitBin} diff --color";
      gdc = "gd --cached";
      gl = "${gitBin} pull";
      glr = "${gitBin} pull --rebase";
      glrp = "glr && gp";
      gp = "${gitBin} push -u";
      gpa = "${gitBin} push all --all";
      gs = "${gitBin} status -sb";
      gsrt = "${gitBin} rev-parse --show-toplevel";
      gsw = "${gitBin} stash show -p";
      gw = "${gitBin} show";
      grt = ''cd -- "$(${gitBin} rev-parse  --show-top-level || echo .)"'';

      nix-gc = "nix-collect-garbage -d";
      nixq = "${nix}/bin/nix-env -qaP";
      home-switch =
        "${home-manager} switch --flake $HOME/.dotfiles#\${USER?}@\${HOST?}";
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
