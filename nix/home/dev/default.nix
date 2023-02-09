{ lib, pkgs, ... }:

{
  imports = [
    ./azure.nix
    ./clojure.nix
    ./kube.nix
    ./gh.nix
  ];

  home.packages = with pkgs;
    [
      # misc
      # hey
      dive
      dtrx # do the right extraction (extract archives)
      jless
      hyperfine
      graphviz
      gnuplot
      gum # fancy scripting
      taplo # toml toolkit

      # protocols
      protobuf
      buf
      grpcurl

      # version control
      pre-commit
      nodePackages_latest.graphite-cli
      delta

      # cloud
      doctl # digital ocean

      # markdown
      mdsh
      glow
      nodePackages_latest.mermaid-cli

      # shell
      shfmt
      shellcheck
      shellharden

      # nix
      alejandra
      nixfmt
      nixpkgs-fmt
      nurl
      nix-init

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

      # java
      java-language-server
      visualvm

      # python
      (python3.withPackages (ps:
        with ps; [
          black
          dbus-python
          ipython
          isort
          jupyterlab
          javaproperties
          javaobj-py3
          notebook
          numpy
          pandas
          pipx
          ptpython
          pygobject3
          pynvim
          requests
          setuptools
        ] ++ [
          # click
          # click-command-tree
          # click-completion
          # click-configfile
          # click-defaultgroup
          # click-datetime
          # click-didyoumean
          # click-log
          # click-repl
          # click-shell
          # click-spinner
          # click-threading
          # clickgen
        ]))
      poetry

      # ruby
      ruby

      # crystal
      crystal
      icr
      shards

      # javascript
      yarn
      deno
      nodePackages.typescript

    ] ++ [
      # language servers
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      nodePackages.vim-language-server
      nodePackages.vscode-langservers-extracted
      pyright
      rnix-lsp
      sumneko-lua-language-server
      yaml-language-server
      java-language-server
    ];

  programs.the-way = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
