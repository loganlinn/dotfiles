{ lib ? (import <nixpkgs> { }).lib }:

with lib.attrsets;

let
  inherit (lib) types nameValuePair;
in
rec {

  /* Replace strings by attrset */
  substitueStrings = m: lib.replaceStrings (attrNames m) (map toString (attrValues m));

  kebabCaseToCamelCase =
    builtins.replaceStrings (map (s: "-${s}") lib.lowerChars) lib.upperChars;

  importDirToAttrs = root: lib.pipe root [
    filesystem.listFilesRecursive
    (builtins.filter (hasSuffix ".nix"))
    (map (path: {
      name = pipe path [
        toString
        (removePrefix "${toString root}/")
        (removeSuffix "/default.nix")
        (removeSuffix ".nix")
        kebabCaseToCamelCase
        (lib.replaceStrings [ "/" ] [ "-" ])
      ];
      value = import path;
    }))
    builtins.listToAttrs
  ];
}
