{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    deadnix
    comma
    nix-init
    # nix-melt # ranger-like flake.lock viewer
    nix-output-monitor # get additional information while building packages
    nix-tree # interactively browse dependency graphs of Nix derivations
    nix-update # swiss-knife for updating nix packages
    nixd # language server
    nixfmt-rfc-style
    nurl
    nvd # nix package version diffs (e.x. nvd diff /run/current-system result)
    nil # language server
    toml2nix
    (writeShellApplication {
      name = "nix-env-print";
      runtimeInputs = [direnv];
      text = ''
        direnv apply_dump <(nix shell --impure "$@" --command "$(command -v direnv)" dump)
      '';
    })
    (writeShellApplication {
      name = "nix-derivation-tree";
      runtimeInputs = [
        jq
        tree
        findutils
      ];
      text = ''
        nix derivation show "$@" | jq '.[].outputs.[].path' | xargs tree
      '';
    })
  ];

  my.shellInitExtra = ''
    source-nix () { source <(nix-env-print "$@"); }
  '';
}
