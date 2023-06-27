{ writeShellApplication, ... }:
writeShellApplication {
  name = "nixos-repl";
  text = ''
    nix repl --file "${../../.}/nixos/repl.nix" "$@"
  '';
}
