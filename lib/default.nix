{ lib, ... }:

with lib;

let
  # Searches Nix path by prefix
  findNixPath = prefix: pipe builtins.nixPath [
    (findFirst (p: p.prefix == prefix) null)
    (mapNullable (p: p.path))
  ];
in
rec {
  inherit findNixPath;

  importNixosConfig = mapNullable import (findNixPath "nixos-config");

  kebabCaseToCamelCase = replaceStrings (map (s: "-${s}") lowerChars) upperChars;

  substitueStrings = m: replaceStrings (attrNames m) (map toString (attrValues m));

  nerdfonts = import ./nerdfonts;

  font-awesome = import ./font-awesome.nix;

  types = import ./types.nix { inherit lib; };

  rofi = import ./rofi.nix { inherit lib; };

  float = import ./float.nix { inherit lib; };

  hex = import ./hex.nix { inherit lib; };

  color = import ./color.nix { inherit lib; };

  getPackageExe = attrs: lib.getExe (attrs.finalPackage or attrs.package);

  ensurePrefix = prefix: content: if hasPrefix prefix content then content else "${content}${prefix}";

  ensureSuffix = suffix: content: if hasSuffix suffix content then content else "${content}${suffix}";

  fileSourceSet = { dir, base ? dir, prefix ? "" }:
    listToAttrs
      (forEach (filesystem.listFilesRecursive dir)
        (source: {
          name = "${prefix}${removePrefix ((toString base) + "/") (toString source)}";
          value = { inherit source; };
        }));
}
