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
    rnix-lsp # lanaguage-server
    nil # language-server
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
    # [INFO] Scanning for projects...
    # [INFO]
    # [INFO] ---------------------< org.javacs:javac-services >----------------------
    # [INFO] Building javac-services 0.1-SNAPSHOT
    # [INFO]   from pom.xml
    # [INFO] --------------------------------[ jar ]---------------------------------
    # [WARNING] The POM for org.apache.maven.plugins:maven-resources-plugin:jar:3.3.1 is missing, no dependency information available
    # [INFO] ------------------------------------------------------------------------
    # [INFO] BUILD FAILURE
    # [INFO] ------------------------------------------------------------------------
    # [INFO] Total time:  0.051 s
    # [INFO] Finished at: 2023-07-30T17:00:15Z
    # [INFO] ------------------------------------------------------------------------
    # [ERROR] Plugin org.apache.maven.plugins:maven-resources-plugin:3.3.1 or one of its dependencies could not be resolved: The following artifacts could not be resolved: org.apache.maven.plugins:maven-resources-pl>
    # [ERROR]
    # [ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
    # [ERROR] Re-run Maven using the -X switch to enable full debug logging.
    # [ERROR]
    # [ERROR] For more information about the errors and possible solutions, please read the following articles:
    # [ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/PluginResolutionException
    # java-language-server
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
    nodePackages.mermaid-cli

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
