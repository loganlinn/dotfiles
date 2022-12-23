{ conf, lib, pkgs, ... }:

{
  home.shellAliases = with pkgs; {
      "'..'"  = "cd ..";
      "'...'" = "cd ...";

      "'?'"  = "which";
      "'??'" = "which -a";

      l   = "ls -lah";
      mkd = "mkdir -p";

      gc   = "${git}/bin/git commit -v";
      gca  = "${git}/bin/git commit -v -a";
      gco  = "${git}/bin/git switch";
      gcm  = "${git}/bin/git switch \"$(${git}/bin/git default-branch || echo .)\"";
      gcob = "${git}/bin/git switch -c";
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

      switch = if stdenv.isDarwin
            then "darwin-rebuild switch --flake ~/.dotfiles"
            else "home-manager switch --flake ~/.dotfiles";

      k = "${kubectl}/bin/kubectl";
      kctx = "${kubectx}/bin/kubectx";
      kusers = "k config get-users";
      kdesc = "k describe";
      kdoc = "k describe";
      kinfo = "k cluster-info";
      kcfg = "k config view --raw";
      kk = "${kustomize}/bin/kustomize";
      kkb = "kk build";

      s = "kitty +kitten ssh";

      bbr = "${rlwrap}/bin/rlwrap bb";
    };
}
