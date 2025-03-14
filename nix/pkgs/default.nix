{
  pkgs ? import <nixpkgs> { },
  ...
}:

let

  inherit (pkgs) lib;

  paths = [
    ./closh
    ./fztea
    ./i3-auto-layout.nix
    ./jib.nix
    ./kubefwd
    ./notify-send-py.nix
    ./age-op
    ./git-spice
  ];

  packages = lib.pipe paths [
    (map (f: pkgs.callPackage f { }))
    (lib.filter (
      p:
      lib.any (
        system:
        let
          platform = lib.systems.elaborate { inherit system; };
        in
        pkgs.stdenv.buildPlatform.canExecute platform
      ) p.meta.platforms
    ))
    (map (p: {
      name = p.pname or p.name;
      value = p;
    }))
    builtins.listToAttrs
  ];

in
packages
