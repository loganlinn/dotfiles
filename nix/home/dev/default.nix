{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isLinux isDarwin;
in
{
  imports = [
    ./azure.nix
    ./jvm.nix
    ./kube.nix
    ./gh.nix
    ./python.nix
    ./nodejs.nix
  ];

  home.packages = with pkgs; [
    openssl

    # benchmarking
    ## hey
    ## hyperfine

    # gfx
    graphviz
    gnuplot

    # filesystem
    as-tree # ex. find . -name '*.txt' | as-tree
    du-dust
    dua # View disk space usage and delete unwanted data, fast.
    watchexec

    # containers
    dive

    # processes
    process-compose

    # terminal
    ## lazycli
    gum
    asciinema
    asciinema-scenario # https://github.com/garbas/asciinema-scenario/

    # data
    buf
    dasel
    grpcurl
    jless
    jq
    protobuf
    taplo # toml
    yamllint
    yq-go
    prom2json # prometheus
    yaml-language-server

    # version control
    pre-commit
    nodePackages_latest.graphite-cli
    delta

    # apis
    doctl
    # google-cloud-sdk

    # web
    htmlq # jq for html
    html2text

    # tools/utils
    xxd # make a hexdump or do the reverse.
    cloc
    just # save and run commands

    ##########################################################################
    # LANGUAGES

    # shell
    shfmt
    shellcheck
    shellharden
    nodePackages.bash-language-server

    # nix
    alejandra
    comma # github.com/nix-community/comma
    deadnix
    nix-init
    nix-output-monitor # get additional information while building packages
    nix-tree # interactively browse dependency graphs of Nix derivations
    nix-update # swiss-knife for updating nix packages
    nixfmt
    nixpkgs-fmt
    nurl
    nvd # nix package version diffs (e.x. nvd diff /run/current-system result)
    rnix-lsp # alt? https://github.com/oxalica/nil
    toml2nix

    # c/c++
    ccls
    clang-tools

    # cue
    cue
    cuelsp

    # rust
    # rustc
    # cargo
    # rustfmt
    # rust-analyzer

    # golang
    gopls

    # vlang
    vlang

    # zig
    zig

    # java
    java-language-server
    # visualvm # conflicts with pkgs.graalvm-ce

    # ruby
    ruby

    # crystal
    crystal
    icr
    shards

    # javascript
    # pnpm # Fast, disk space efficient package manager
    nodejs
    yarn
    yarn-bash-completion
    nodePackages.typescript-language-server
    # deno
    # nodePackages.typescript

    # graphql
    nodePackages.graphql-language-service-cli

    # markdown
    mdsh
    glow
    nodePackages_latest.mermaid-cli

    # vim
    nodePackages.vim-language-server
    sumneko-lua-language-server
  ] ++ lib.optional config.programs.vscode.enable
    nodePackages.vscode-langservers-extracted;

  home.sessionVariables = {
    GRAPHITE_DISABLE_TELEMETRY = "1";
    NEXT_TELEMETRY_DISABLED = "1";
  } // lib.optionalAttrs isDarwin {
    HOMEBREW_NO_ANALYTICS = "1";
  };
}
