pkgs:
let inherit (pkgs.lib) mkMerge optionalAttrs mapAttrs;
in mapAttrs (_: f: pkgs.callPackage f { }) ({
  closh = ./closh;
  kubefwd = ./kubefwd;
  fztea = ./fztea;
} // (optionalAttrs pkgs.stdenv.isLinux {
  i3-auto-layout = ./os-specific/linux/i3-auto-layout.nix;
  graphite-cli = ./os-specific/linux/graphite-cli.nix;
  notify-send-py = ./os-specific/linux/notify-send-py.nix;
}))
