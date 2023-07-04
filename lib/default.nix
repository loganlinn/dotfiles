{ lib, ... }:

with lib;

let
  # Searches Nix path by prefix
  findNixPath = prefix: pipe builtins.nixPath [
    (findFirst (p: p.prefix == prefix) null)
    (mapNullable (p: p.path))
  ];
in
{
  inherit findNixPath;

  importNixosConfig = mapNullable import (findNixPath "nixos-config");

  kebabCaseToCamelCase = replaceStrings (map (s: "-${s}") lowerChars) upperChars;

  substitueStrings = m: replaceStrings (attrNames m) (map toString (attrValues m));

  nerdfonts = import ./nerdfonts;

  font-awesome = import ./font-awesome.nix;

  rofi = import ./rofi.nix { inherit lib; };

  float = import ./float.nix { inherit lib; };

  hex = import ./hex.nix { inherit lib; };

  color = import ./color.nix { inherit lib; };
}
