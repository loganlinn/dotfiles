{pkgs, ...}: {
  imports = [
    ./clojure.nix
    ./azure.nix
    ./k8s.nix
    #   ./crystal.nix
  ];

  home.packages = with pkgs; [
    # version control
    pre-commit
    nodePackages.graphite-cli
    git-branchless
    git-crypt

    # general
    xh
    hey
    meld
    protobuf
    buf
    # bazel

    # crystal
    # crystal
    # icr # crystal repl
    # shards # package-manager

    # shell
    shfmt
    shellcheck
    shellharden
    mdsh

    # nix
    alejandra # formatter
    nixfmt
    nixpkgs-fmt # nix formatter

    # ruby
    ruby

    # rust
    rustc
    cargo
    rustfmt
    rust-analyzer

    # javascript
    yarn
    deno

    # kubernetes
    krew # required after install: krew install krew
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    stern
    kind
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };
}
