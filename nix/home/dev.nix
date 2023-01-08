{lib, pkgs, ...}: {
  imports = [
    ./azure.nix
    ./clojure.nix
    ./crystal.nix
    ./k8s.nix
    ./gh.nix
  ];

  home.packages = with pkgs; [
    # version control
    pre-commit
    nodePackages_latest.graphite-cli
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

    # services
    doctl

    # shell
    shfmt
    shellcheck
    shellharden
    mdsh

    # nix
    alejandra
    nixfmt
    nixpkgs-fmt
    rnix-lsp

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
    kubelogin
    kubernetes-helm
    kustomize
    stern
    kind
  ];

  programs.nix-index.enable = lib.mkDefault false;
}
