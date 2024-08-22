nixos_rebuild := "nixos-rebuild --accept-flake-config --show-trace"

switch:
  {{ nixos-rebuild }} switch

build:
  {{ nixos-rebuild }} build

test:
  {{nixos-rebuild }} test

boot:
  {{ nixos-rebuild }} boot

repl:
  {{ source_dir() }}/nixos/repl
