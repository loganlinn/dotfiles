{writeShellApplication, ...}:
writeShellApplication {
  name = "repl";
  text = ''
    nix repl --file "${../../.}/repl.nix" "$@"
  '';
}
