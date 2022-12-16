{pkgs, ...}: {
  imports = [
    ./azure.nix
    ./clojure.nix
    ./crystal.nix
    ./k8s.nix
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
    dive
    delta
    jless
    protobuf
    buf
    hyperfine
    graphviz
    # meld
    # bazel

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
}
