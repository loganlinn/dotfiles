#! /usr/bin/env nix
#! nix shell nixpkgs#just nixpkgs#gum --command just --justfile

# mod nixos
# mod windows
# mod firewalla

default: help

help:
    @just --list --unsorted

@link-flake:
    just link-system-flake
    just link flake.nix ~/.config/home-manager/flake.nix

[macos]
@link-system-flake:
    just link flake.nix /etc/nix-darwin/flake.nix

[linux]
@link-system-flake:
    just link flake.nix /etc/nixos/flake.nix

[macos]
bootstrap:
    nix run nix-darwin -- switch --flake {{ source_dir() }}
    just link-flake

[macos]
rebuild *args:
    darwin-rebuild {{ args }}

[linux]
rebuild *args:
    nixos-rebuild {{ args }}

[macos]
switch *args:
    darwin-rebuild switch --flake {{ source_dir() }} {{ args }}

[linux]
switch *args:
    nixos-rebuild switch --flake {{ source_dir() }} {{ args }}

# update flake inputs
update *inputs:
    nix flake update {{ inputs }}

repl dir='.' file='repl.nix' args="":
    nix repl --verbose --trace-verbose --file {{ dir }}/{{ file }} {{ args }}

run app *args:
    nix run .#{{ app }} {{ args }}

netrc:
    op inject -i netrc.tpl -o ~/.netrc

flake-checker:
    env FLAKE_CHECKER_NO_TELEMETRY=true nix run github:DeterminateSystems/flake-checker

[linux]
[macos]
fix-eol:
    rg -g '!windows/*' -l -0 $'\r$' | xargs -0 dos2unix --

[private]
@link path link context=source_dir():
    #!/usr/bin/env bash
    target="{{ clean(join(context, path)) }}"
    link="{{ clean(link) }}"
    if [ ! -d "$(dirname "$link")" ]; then
      echo "{{BOLD}}{{YELLOW}} skipped:{{RESET}} {{BLUE}}$(dirname "$link"){{RESET}} does not exist";
    elif [ "$(readlink -qe "$link")" = "$(readlink -qe "$target")" ]; then
      echo "{{BOLD}}{{GREEN}}   found:{{RESET}} {{BLUE}}$link{{RESET}} -> {{BLUE}}$target{{RESET}}";
    else
      ln -s -T "$target" "$link";
      echo "{{BOLD}}{{GREEN}} created:{{RESET}} {{BLUE}}$link{{RESET}} -> {{BLUE}}$target{{RESET}}";
    fi;

fmt:
    nix fmt
    just --fmt --unstable
