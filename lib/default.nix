{ lib
, system ? builtins.currentSystem
, inputs ? (builtins.getFlake (toString ./.)).inputs
, ...
}:

let

  inherit (builtins)
    getFlake
    isAttrs
    replaceStrings
    toString
    ;

  inherit (lib) mkOption;

  pkgs = import inputs.nixpkgs { inherit system; };

in
rec {
  types = {
    inherit (inputs.home-manager.lib.hm.types) fontType;

    script = with lib.types; submodule {
      options = {
        text = mkOption {
          type = str;
          description = "Shell code to execute when the script is ran.";
        };
        runtimeInputs = mkOption {
          type = listOf package;
          default = [ ];
        };
        checkPhase = mkOption {
          type = nullOr string;
          default = null;
        };
      };
    };
  };

  mkScript = name: value:
    let attrs = if isAttrs value then value else { text = toString value; }; in
    pkgs.writeShellApplication ({ inherit name; } // attrs);

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
