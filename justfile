#!/usr/bin/env nix-shell
#!nix-shell -i "just --justfile" -p just

mod nixos

# mod windows
# mod firewalla

# default recipe to display help information
default:
    @just --list

fmt:
    nix fmt
    just --fmt --unstable

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
update +inputs:
    nix flake lock --commit-lock-file {{ prepend("--update-input ", inputs) }}

repl dir='.' file='repl.nix' args="":
    nix repl --verbose --trace-verbose --file {{ dir }}/{{ file }} {{ args }}

run app *args:
    nix run .#{{ app }} {{ args }}

netrc:
    op inject -i netrc.tpl -o ~/.netrc

flake-checker:
    nix run github:DeterminateSystems/flake-checker

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


BOLD := "$(tput bold)"
RESET := "$(tput sgr0)"
BLACK := "$(tput bold)$(tput setaf 0)"
RED := "$(tput bold)$(tput setaf 1)"
GREEN := "$(tput bold)$(tput setaf 2)"
YELLOW := "$(tput bold)$(tput setaf 3)"
BLUE := "$(tput bold)$(tput setaf 4)"
MAGENTA := "$(tput bold)$(tput setaf 5)"
CYAN := "$(tput bold)$(tput setaf 6)"
WHITE := "$(tput bold)$(tput setaf 7)"
BLACKB := "$(tput bold)$(tput setab 0)"
REDB := "$(tput setab 1)$(tput setaf 0)"
GREENB := "$(tput setab 2)$(tput setaf 0)"
YELLOWB := "$(tput setab 3)$(tput setaf 0)"
BLUEB := "$(tput setab 4)$(tput setaf 0)"
MAGENTAB := "$(tput setab 5)$(tput setaf 0)"
CYANB := "$(tput setab 6)$(tput setaf 0)"
WHITEB := "$(tput setab 7)$(tput setaf 0)"
