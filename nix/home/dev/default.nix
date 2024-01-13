{ config, lib, pkgs, ... }:

{
  imports = [
    ../java
    ../just
    ../python
    ./azure.nix
    ./bazel.nix
    ./clang.nix
    ./crystal.nix
    ./cue.nix
    ./golang.nix
    ./images.nix
    ./kube.nix
    ./markdown.nix
    ./nodejs.nix
    ./protobuf.nix
    ./ruby.nix
    ./rust.nix
    ../git
    ./data.nix
    ./nix.nix
    ./shell.nix
  ];

  home.packages = with pkgs; [
    # as-tree          # ex. find . -name '*.txt' | as-tree
    # dive             # docker image layer explorer
    # docker-slim
    # doctl            # digitalocean
    # dua              # View disk space usage and delete unwanted data, fast.
    # google-cloud-sdk
    # hey              # http load generator
    # hyperfine        # cli benchmarking tool
    # process-compose  # process manager a la docker-compose
    du-dust
    entr               # similar to watchexec
    libossp_uuid       # i.e. uuid(1)
    # openssl
    # universal-ctags
    sops
    tree
    unzip
    xh # httpie alternative
    zip
  ];
}
