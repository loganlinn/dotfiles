{ lib }:

let mkMyLib = import ./.; in
rec {

  my = (lib.extend (self: super: {
    my = mkMyLib { lib = self; };
  })).my

    inherit (lib)
    optional optionalAttrs optionalString optionals

    mkAssert mkAfter mkBefore mkDefault mkIf mkMerge mkForce mkOrder mkOverride
    mkOption mkOptionType mkEnableOption mkOptionDefault mkPackageOption
    mkRenamedOptionModuleWith mkRenamedOptionModule mkMergedOptionModule mkRemovedOptionModule mkAliasOptionModule
    mkDerivedConfig mkAliasAndWrapDefinitions mkAliasDefinitions
  ;

  # Searches Nix path by prefix
  # Example: findNixPath "nixos-config"
  findNixPath = prefix: lib.pipe builtins.nixPath [
    (lib.findFirst (p: p.prefix == prefix) null)
    (lib.mapNullable (p: p.path))
  ];

  importNixosConfig = lib.mapNullable import (findNixPath "nixos-config");

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
