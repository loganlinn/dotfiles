{ writeShellApplication, ... }:
writeShellApplication {
  name = "home-repl";
  text = ''
    nix repl --file "${../../.}/home-manager/repl.nix" "$@"
  '';
}
