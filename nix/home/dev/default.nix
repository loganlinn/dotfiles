{ lib, pkgs, ... }:

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
    dtrx # do the right extraction (extract archives)
    jless
    hyperfine
    graphviz
    gnuplot
    nodePackages.vscode-langservers-extracted # LSP (HTML/CSS/JSON/ESLint)

    # version control
    pre-commit
    nodePackages_latest.graphite-cli
    delta

    # scripting
    gum

    # clients
    doctl

    # shell
    shfmt
    shellcheck
    shellharden
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
    (python3.withPackages (ps: with ps; [
      black
      dbus-python
      ipython
      isort
      jupyterlab
      notebook
      numpy
      pandas
      pipx
      ptpython
      pygobject3
      pynvim
      requests
      setuptools
    ]))
    poetry
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
    glow
  ];

  programs.the-way = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
