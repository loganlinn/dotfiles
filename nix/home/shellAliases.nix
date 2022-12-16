{ pkgs, ... }:

{
  home.shellAliases = with pkgs; {
      ".."  = "cd ..";
      "..." = "cd ...";

      "'?'"  = "which";
      "'??'" = "which -a";

      gc   = "${git}/bin/git commit -v";
      gco  = "${git}/bin/git checkout -b";
      gcob = "${git}/bin/git checkout -b";
      gcop = "${git}/bin/git checkout -p";
      gd   = "${git}/bin/git diff --color";
      gdc  = "${git}/bin/git diff --color --cached";
      gl   = "${git}/bin/git pull";
      glr  = "${git}/bin/git pull --rebase";
      glrp = "glr && gp";
      gp   = "${git}/bin/git push -u";
      gpa  = "${git}/bin/git push all --all";
      gs   = "${git}/bin/git status -sb";
      gsrt = "${git}/bin/git rev-parse --show-toplevel";
      gsw  = "${git}/bin/git stash show -p";
      gw   = "${git}/bin/git show";
      grt  = ''cd -- "$(${git}/bin/git rev-parse  --show-top-level || echo .)"'';

      nix-gc = "${nix}/bin/nix-collect-garbage -d";
      nixq = "${nix}/bin/nix-env -qaP";
      os-switch = "sudo ${nix}/bin/nixos-rebuild switch";
      hm = "${home-manager}/bin/home-manager";
      hm-switch = "${home-manager}/bin/home-manager switch --flake \"$HOME/.dotfiles#\${USER?}@\${HOST?}\"";

      k = "${kubectl}/bin/kubectl";
      kctx = "${kubectx}/bin/kubectx";
      kusers = "k config get-users";
      kdesc = "k describe";
      kdoc = "k describe";
      kinfo = "k cluster-info";
      kcfg = "k config view --raw";
      kk = "${kustomize}/bin/kustomize";
      kkb = "kk build";

      bbr = "${rlwrap}/bin/rlwrap bb";
    };
}
