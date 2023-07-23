{ config, ... }:
{
  "'..'" = "cd ..";
  "'...'" = "cd ...";
  l = "ls -lah";
  mkd = "mkdir -p";

  prunedirs = "fd -td -te -x rmdir -v";

  gc = "git commit -v";
  gca = "git commit -v -a";
  gcm = ''git switch "$(git default-branch || echo .)"'';
  gcob = "git switch -c";
  gcop = "git checkout -p";
  gd = "git diff --color";
  gdc = "git diff --color --cached";
  gfo = "git fetch origin";
  gl = "git pull";
  glr = "git pull --rebase";
  glrp = "glr && gp";
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

  # Kubernetes
  k = "kubectl";
  kctx = "kubectx";
  kk = "kustomize";
  kkb = "kustomize build";

  epoch = "date +%s";
  today = "date -Idate";

  flake = ''env -C "''${FLAKE_ROOT-${config.my.flakeRoot}}" nix flake'';
}
