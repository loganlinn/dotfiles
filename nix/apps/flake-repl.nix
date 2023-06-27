{ writeShellApplication, ... }:
writeShellApplication {
  name = "flake-repl";
  text = ''
    nix repl --file "${../../.}/repl.nix" "$@"
  '';
}
