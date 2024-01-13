{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
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
  ];
}
