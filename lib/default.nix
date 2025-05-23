{
  pkgs ? import (import ../.).inputs.nixpkgs {},
  lib ? pkgs.lib,
  ...
}: let
  getEnvOr = name: fallback: let
    value = builtins.getEnv name;
  in
    if value != ""
    then value
    else fallback;

  flakeRoot = getEnvOr "FLAKE_ROOT" (toString ./..);

  toExe = input:
    if lib.isDerivation input
    then lib.getExe input
    else if lib.isAttrs input
    then lib.getExe (input.finalPackage or input.package)
    else throw "Cannot coerce ${input} to main executable program path.";
in {
  inherit getEnvOr flakeRoot toExe;
  currentHostname = import ./currentHostname.nix {inherit pkgs lib;};
  types = import ./types.nix {inherit lib;};
  files = import ./files.nix {inherit lib;};
  strings = import ./strings.nix {inherit lib;};
  float = import ./float.nix {inherit lib;};
  hex = import ./hex.nix {inherit lib;};
  color = import ./color.nix {inherit lib;};
  nerdfonts = import ./nerdfonts {inherit lib;};
  font-awesome = import ./font-awesome.nix {inherit lib;};
  # rofi = import ./rofi.nix { inherit lib; };
}
