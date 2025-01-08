{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../git
    ../java
    ../just
    ../python
    ./clang.nix
    ./data.nix
    ./golang.nix
    ./images.nix
    ./kube.nix
    ./markdown.nix
    ./nix.nix
    ./nodejs.nix
    ./protobuf.nix
    ./ruby.nix
    ./rust.nix
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
    diskus # fast `du -sh`
    du-dust # du replacement
    entr # similar to watchexec
    gum
    sops
    tree
    unzip
    xh # httpie alternative
    zip
  ];
}
