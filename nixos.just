nixos_rebuild := "nixos-rebuild --accept-flake-config --show-trace"

switch:
  {{ nixos_rebuild }} switch

build:
  {{ nixos_rebuild }} build

test:
  {{nixos_rebuild }} test

boot:
  {{ nixos_rebuild }} boot

repl:
  {{ source_dir() }}/nixos/repl
