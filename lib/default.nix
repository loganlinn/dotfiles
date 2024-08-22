{ lib ? (import ../.).inputs.nixpkgs.lib, ... }:

{
  types = import ./types.nix { inherit lib; };
  files = import ./files.nix { inherit lib; };
  strings = import ./strings.nix { inherit lib; };

  float = import ./float.nix { inherit lib; };
  hex = import ./hex.nix { inherit lib; };
  color = import ./color.nix { inherit lib; };

  nerdfonts = import ./nerdfonts { inherit lib; };
  font-awesome = import ./font-awesome.nix { inherit lib; };

  # rofi = import ./rofi.nix { inherit lib; };

  # Returns
  toExe = input:
    if lib.isDerivation input then
      lib.getExe input
    else if lib.isAttrs input then
      lib.getExe (input.finalPackage or input.package)
    else
      throw "Cannot coerce ${input} to main executable program path.";

  currentHostname = if lib.pathExists "/etc/hostname" then
    lib.pipe "/etc/hostname" [
      builtins.readFile
      (builtins.match ''
        ^([^#].*)
        $'')
      builtins.head
    ]
  else
    let v = builtins.getEnv "HOSTNAME";
    in if v == "" then lib.warn "Unable to detect system hostname" null else v;
}
