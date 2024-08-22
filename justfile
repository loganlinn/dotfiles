#!/usr/bin/env nix-shell
#!nix-shell -i "just --justfile" -p just

# default recipe to display help information
default:
  @just --list

flake := invocation_directory()

alias s := switch
alias b := build
alias z := repl

[linux]
build:
    nix run home-manager -- build

[macos]
build:
    darwin-rebuild build --flake {{ flake }}

[linux]
switch:
    nix run home-manager -- switch

[macos]
switch:
    darwin-rebuild switch --flake {{ flake }}

[linux]
bootstrap:
    nix run home-manager -- init --switch

[macos]
bootstrap:
    nix build "{{ flake }}#darwinConfigurations.$(hostname -s).system"
    ./result/sw/bin/darwin-rebuild switch --flake {{ invocation_directory() }}

fmt:
    nix fmt
    just --fmt --unstable

update:
    nix flake update --commit-lock-file

show:
    nix flake show

metadata:
    nix flake metadata

repl dir='.' file='repl.nix':
    nix repl --file {{dir}}/{{ file }}

run app:
    nix run .#{{ app }}

use-caches: (run "use-caches")
home-switch: (run "home-switch")
nixos-switch: (run "nixos-switch")

netrc:
    op inject -i netrc.tpl -o ~/.netrc
