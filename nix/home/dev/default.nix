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
    ../python
    ./nodejs.nix
    ../just
  ];

  home.packages = with pkgs; [
    openssl
    libossp_uuid # uuid command
    universal-ctags

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
    entr      # better than watchexec?

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
    # cue
    # cue
    # cuelsp

    # version control
    pre-commit
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

    ##########################################################################
    # LANGUAGES

    # shell
    shfmt
    shellcheck
    shellharden
    nodePackages.bash-language-server

    # nix
    alejandra
    deadnix
    comma
    nix-init
    nix-melt # ranger-like flake.lock viewer
    nix-output-monitor # get additional information while building packages
    nix-tree # interactively browse dependency graphs of Nix derivations
    nix-update # swiss-knife for updating nix packages
    nixd # language server
    nixfmt
    nixpkgs-fmt
    nurl
    nvd # nix package version diffs (e.x. nvd diff /run/current-system result)
    rnix-lsp # lanaguage server
    nil # language server
    toml2nix

    # c+++++++++++++
    ccls
    clang-tools
    # vlang
    # zig

    # golang
    gopls

    lua
    luarocks
    luaformatter
    lua-language-server
    fennel
    fnlfmt

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
    nodePackages.mermaid-cli

    # vim
    nodePackages.vim-language-server
  ] ++ lib.optional config.programs.vscode.enable
    nodePackages.vscode-langservers-extracted;

  programs.go.enable = true;

  home.sessionVariables = {
    GRAPHITE_DISABLE_TELEMETRY = "1";
    NEXT_TELEMETRY_DISABLED = "1";
  } // lib.optionalAttrs isDarwin {
    HOMEBREW_NO_ANALYTICS = "1";
  };
}
