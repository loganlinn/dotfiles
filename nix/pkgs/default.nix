pkgs:

{
  closh = pkgs.callPackage ./closh { };
  kubefwd = pkgs.callPackage ./kubefwd.nix { };
} // (if pkgs.stdenv.isLinux then {
  i3-auto-layout = pkgs.callPackage ./os-specific/linux/i3-auto-layout.nix { };
  graphite-cli = pkgs.callPackage ./os-specific/linux/graphite-cli.nix { };
} else if pkgs.stdenv.isDarwin then
  { }
else
  { })
