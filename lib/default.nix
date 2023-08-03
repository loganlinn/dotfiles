{ lib, ... }:

with lib;

let
  types = import ./types.nix { inherit lib; };

  nerdfonts = import ./nerdfonts;

  font-awesome = import ./font-awesome.nix;

  rofi = import ./rofi.nix { inherit lib; };

  float = import ./float.nix { inherit lib; };

  hex = import ./hex.nix { inherit lib; };

  color = import ./color.nix { inherit lib; };

  toExe = input:
    if isDerivation input then getExe input
    else if isAttrs input then getExe (input.finalPackage or input.package)
    else throw "Cannot coerce ${input} to main executable program path.";

  currentHostname =
    if pathIsRegularFile "/etc/hostname" then
      pipe "/etc/hostname" [ readFile (match "^([^#].*)\n$") head ]
    else
      pipe "HOSTNAME" [ getEnv (warn "Unable to detect system hostname") ];

  files = {
    sourceSet = { dir, base ? dir, prefix ? "" }:
      listToAttrs
        (forEach (filesystem.listFilesRecursive dir)
          (source: {
            name = "${prefix}${removePrefix ((toString base) + "/") (toString source)}";
            value = { inherit source; };
          }));
  };

  strings = {
    substitute = dict: replaceStrings (attrNames dict) (map toString (attrValues dict));
    ensurePrefix = prefix: content: if hasPrefix prefix content then content else "${content}${prefix}";
    ensureSuffix = suffix: content: if hasSuffix suffix content then content else "${content}${suffix}";
  };

in
{
  inherit
    types
    options
    nerdfonts font-awesome
    rofi
    float
    hex
    color
    toExe
    currentHostname
    files
    strings
    mkSystemRepl
    ;
}
