{ nixpkgs
, config
, ...
}: {
  xdg.configFile."nix/inputs/nixpkgs".source = nixpkgs.outPath;

  home.sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/inputs/nixpkgs\${NIX_PATH:+:$NIX_PATH}";
}
