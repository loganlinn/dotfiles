{ config, lib, pkgs, ... }:

let
  inherit (lib) optionals;
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  imports = [
    ./azure.nix
    ./jvm.nix
    ./kube.nix
    ./gh.nix
    ./python.nix
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
    ranger
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

    # version control
    pre-commit
    nodePackages_latest.graphite-cli
    delta

    # apis
    doctl
    # python3Packages.datadog # conflicts with dog (dns tool)
    # google-cloud-sdk

    # tools/utils
    xxd # make a hexdump or do the reverse.
    cloc

    ##########################################################################
    # LANGUAGES

    # shell
    shfmt
    shellcheck
    shellharden
    ## docopts

    # nix
    alejandra
    nixfmt
    nixpkgs-fmt
    nurl
    nix-init
    deadnix
    statix
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
    deno
    nodePackages.typescript

    # graphql
    nodePackages.graphql-language-service-cli

    # markdown
    mdsh
    glow
    nodePackages_latest.mermaid-cli

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

  home.sessionVariables.GRAPHITE_DISABLE_TELEMETRY = "1";

  xdg.configFile."ranger/rc.conf".text = ''
    set vcs_aware false
    map zg set vcs_aware true
    setlocal path=${config.xdg.userDirs.download} sort mtime
  '';
}
