{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../git
    ../just
    ../python
    ./clang.nix
    ./data.nix
    ./golang.nix
    ./graphics.nix
    ./javascript.nix
    ./markdown.nix
    ./nix.nix
    ./protobuf.nix
    ./python.nix
    ./ruby.nix
    ./rust.nix
    ./shell.nix
  ];

  home.packages = with pkgs; [
    entr
    gum
    process-compose
    sad
    tree
    # unipicker
    unzip
    watch
    xh
    zip
  ];

  home.shellAliases = {
    g = "git";
  };
}
