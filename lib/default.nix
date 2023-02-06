{ lib, ... }:

let

  inherit (builtins) getFlake replaceStrings;

  home-manager = (getFlake (toString ./.)).inputs.home-manager;

in
rec {
  types = {
    inherit (home-manager.lib.hm.types) fontType;
  };

  /* Replace strings by attrset
    Type: substitueStrings :: AttrSet -> String -> String
  */
  substitueStrings = m: replaceStrings (lib.attrNames m) (map toString (lib.attrValues m));

  # Type: kebabCaseToCamelCase :: String -> String
  kebabCaseToCamelCase = replaceStrings (map (s: "-${s}") lib.lowerChars) lib.upperChars;

  # Type: importDirToAttrs :: Path -> AttrSet
  importDirToAttrs = with lib; root:
    pipe root [
      filesystem.listFilesRecursive
      (filter (hasSuffix ".nix"))
      (map (path: {
        name = lib.pipe path [
          toString
          (removePrefix "${toString root}/")
          (removeSuffix "/default.nix")
          (removeSuffix ".nix")
          kebabCaseToCamelCase
          (replaceStrings [ "/" ] [ "-" ])
        ];
        value = import path;
      }))
      listToAttrs
    ];
}
