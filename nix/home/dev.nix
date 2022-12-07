{pkgs, ...}: {
  home.packages = with pkgs; [
    # general
    xh
    hey
    meld
    protobuf
    buf
    git-branchless
    bazel
    pre-commit

    # crystal
    crystal
    icr # crystal repl
    shards # package-manager

    # shell
    shfmt
    shellcheck
    shellharden

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
    k9s
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
