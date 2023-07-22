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

  dotfiles-run = ''() { ( cd "''${DOTFILES_DIR-$HOME/.dotfiles}" && nix run ".#''${@}"; ) }'';
  dotfiles-repl = "dotfiles-run flake-repl";
  home-repl = "dotfiles-run home-repl";
  home-switch = "dotfiles-run home-switch";
  nixos-repl = "dotfiles-run nixos-repl";
  nixos-switch = "dotfiles-run nixos-switch";
}
