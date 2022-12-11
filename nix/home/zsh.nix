{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    defaultKeymap = "emacs";
    sessionVariables = {EDITOR = "vim";};
    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      path = "${config.xdg.dataHome}/zsh/history";
      share = false;
      size = 100000;
      save = 100000;
    };
    shellAliases = {
      "'?'" = "which";
      "'??'" = "which -a";
      ".." = "cd ..";
      et = "emacs -nw";

      gc = "git commit -v";
      gcob = "git checkout -b";
      gcop = "git checkout -p";
      gd = "git diff --color";
      gdc = "gd --cached";
      gl = "git pull";
      glr = "git pull --rebase";
      glrp = "glr && gp";
      gp = "git push -u";
      gpa = "git push all --all";
      gs = "git status -sb";
      gsrt = "git rev-parse --show-toplevel";
      gsw = "git stash show -p";
      gw = "git show";
      gwt = "git worktree";
      gwt-ls = ''
        git worktree list --porcelain 2>/dev/null | awk "/^worktree / { print $2 }"'';
      gwt-rm = "gwt-ls | fzf | ifne xargs git worktree remove";

      nix-gc = "nix-collect-garbage -d";
      nixq = "nix-env -qaP";
      home-switch = "home-manager switch --flake ~/.dotfiles#\${USER?}@\${HOST?}";
      hm = "home-manager";
      hm-switch = "home-switch";

      k = "kubectl";
      kctx = "kubectx";
      kusers = "k config get-users";
      kdesc = "k describe";
      kdoc = "k describe";
      kinfo = "k cluster-info";
      kcfg = "k config view --raw";
      kk = "kustomize";
      kkb = "kk build";

      bbr = "rlwrap bb";
    };
    dirHashes = {
      cfg = "$HOME/.config";
      nix = "$HOME/.dotfiles/nix";
      dot = "$HOME/.dotfiles";
      docs = "$HOME/Documents";
      dl = "$HOME/Downloads";
      src = "$HOME/src";
      gh = "$HOME/src/github.com";
      ptech = "$HOME/src/github.com/patch-tech";
      cljsrc = "$HOME/src/github.com/clojure/clojure/src/clj/clojure";
    };
    initExtra = ''
      . ~/.dotfiles/bin/src-get
    '';
  };
}
