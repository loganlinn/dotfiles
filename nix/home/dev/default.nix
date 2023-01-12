{lib, pkgs, ...}:

{
  imports = [
    ./azure.nix
    ./clojure.nix
    ./crystal.nix
    ./kube.nix
    ./gh.nix
  ];

  home.packages = with pkgs; [
    # misc
    hey
    dive
    jless
    hyperfine
    graphviz
    gnuplot
    nodePackages.vscode-langservers-extracted # LSP (HTML/CSS/JSON/ESLint)

    # version control
    pre-commit
    nodePackages_latest.graphite-cli
    delta

    # clients
    doctl

    # shell
    shfmt
    shellcheck
    shellharden
    mdsh
    nodePackages.bash-language-server

    # nix
    alejandra
    nixfmt
    nixpkgs-fmt
    rnix-lsp
    nurl

    # c/c++
    ccls
    clang-tools

    # rust
    rustc
    cargo
    rustfmt
    rust-analyzer

    # golang
    gopls

    # python
    python3
    python3Packages.ptpython
    pyright

    # ruby
    ruby

    # javascript
    yarn
    deno
    nodePackages.typescript
    nodePackages.typescript-language-server

    # lua
    sumneko-lua-language-server

    # vim
    nodePackages.vim-language-server

    # yaml
    yaml-language-server

    # protocol buffers
    protobuf
    buf

    # markdown
    mdsh
  ];
}
