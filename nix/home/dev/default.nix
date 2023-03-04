{ config, lib, pkgs, ... }:

let
  inherit (lib) optionals;
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  imports = [
    ./azure.nix
    ./clojure.nix
    ./kube.nix
    ./gh.nix
  ];

  home.packages = with pkgs;
    [
      # benchmarking
      hey
      hyperfine

      # gfx
      graphviz
      gnuplot

      # filesystem
      as-tree
      du-dust
      dua # View disk space usage and delete unwanted data, fast.
      ranger
      watchexec

      # containers
      dive

      # processes
      process-compose

      # terminal
      lazycli
      gum
      asciinema
      asciinema-scenario # https://github.com/garbas/asciinema-scenario/

      # toml
      taplo

      # data
      protobuf
      buf
      grpcurl

      # version control
      pre-commit
      nodePackages_latest.graphite-cli
      delta

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
      deadnix
      statix

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
      # pnpm # Fast, disk space efficient package manager
      yarn
      yarn-bash-completion
      deno
      nodePackages.typescript

      # graphql
      nodePackages.graphql-language-service-cli

      # json
      jq
      jless

      # yaml
      yamllint

      # apis
      doctl
      # python3Packages.datadog # conflicts with dog (dns tool)
      # google-cloud-sdk

      # tools/utils
      xxd # make a hexdump or do the reverse.
      cloc

    ] ++ [

      # language servers
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      nodePackages.vim-language-server
      nodePackages.vscode-langservers-extracted
      pyright
      rnix-lsp # alt? https://github.com/oxalica/nil
      sumneko-lua-language-server
      yaml-language-server
      java-language-server

    ] ++ optionals isLinux [

      # system76-keyboard-configurator

    ];

  xdg.configFile."ranger/rc.conf".text = ''
    set vcs_aware false
    map zg set vcs_aware true
  '';
}
