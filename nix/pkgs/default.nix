{ pkgs ? import <nixpkgs> { } }:

let

  inherit (pkgs) lib;

  packages = [
    ./closh
    ./kubefwd
    ./fztea
    ./os-specific/linux/i3-auto-layout.nix
    ./os-specific/linux/graphite-cli.nix
    ./os-specific/linux/notify-send-py.nix
  ];

in lib.mapAttrs (_: f: pkgs.callPackage f { }) ({
  closh = ./closh;
  kubefwd = ./kubefwd;
  fztea = ./fztea;
} // (lib.optionalAttrs pkgs.stdenv.isLinux {
  i3-auto-layout = ./os-specific/linux/i3-auto-layout.nix;
  graphite-cli = ./os-specific/linux/graphite-cli.nix;
  notify-send-py = ./os-specific/linux/notify-send-py.nix;
}))
