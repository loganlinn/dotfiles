nixos_rebuild := "nixos-rebuild --accept-flake-config --show-trace"

test:
  {{nixos_rebuild }} test

switch:
  {{ nixos_rebuild }} switch

build:
  sudo {{ nixos_rebuild }} build

boot:
  sudo {{ nixos_rebuild }} boot

repl:
  {{ source_dir() }}/nixos/repl
