nixos_rebuild := "nixos-rebuild --accept-flake-config --show-trace"

test args='':
  {{nixos_rebuild }} test {{ args }}

switch args='':
  sudo {{ nixos_rebuild }} switch {{ args }}

build args='':
  {{ nixos_rebuild }} build {{ args }}

boot args='':
  sudo {{ nixos_rebuild }} boot {{ args }}

repl:
  ./repl
