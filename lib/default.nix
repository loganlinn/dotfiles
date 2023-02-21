lib:

with lib;

rec {
  nerdfonts = importDirToAttrs ./nerdfonts;

  # Searches Nix path by prefix
  # Example: findNixPath "nixos-config"
  findNixPath = prefix: pipe builtins.nixPath [
    (findFirst (p: p.prefix == prefix) null)
    (mapNullable (p: p.path))
  ];

  importNixosConfig = mapNullable import (findNixPath "nixos-config");

  /* Replace strings by attrset
    Type: substitueStrings :: AttrSet -> String -> String
  */
  substitueStrings = m: replaceStrings (attrNames m) (map toString (attrValues m));

  # Type: kebabCaseToCamelCase :: String -> String
  kebabCaseToCamelCase = replaceStrings (map (s: "-${s}") lowerChars) upperChars;

  # Type: importDirToAttrs :: Path -> AttrSet
  importDirToAttrs = with lib; root:
    pipe root [
      filesystem.listFilesRecursive
      (filter (hasSuffix ".nix"))
      (map (path: {
        name = pipe path [
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

  unionOfDisjoint = x: y:
    let
      intersection = builtins.intersectAttrs x y;
      collisions = lib.concatStringsSep " " (builtins.attrNames intersection);
      mask = builtins.mapAttrs
        (name: value: builtins.throw
          "unionOfDisjoint: collision on ${name}; complete list: ${collisions}")
        intersection;
    in
    (x // y) // mask;
}
