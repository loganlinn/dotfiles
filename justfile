#! /usr/bin/env nix

import? 'justfile.local'

#! nix shell nixpkgs#just nixpkgs#gum --command just --justfile
# mod nixos
# mod windows
# mod firewalla

set shell := ["bash", "-e", "-u", "-o", "pipefail", "-c"]
set unstable := true

[private]
[script]
default:
    while true; do
      if ! just --choose --unsorted; then
        echo $?
        echo "Exiting..."
        exit 0
      fi
    done

[macos]
switch *args:
    darwin-rebuild switch --flake {{ source_dir() }} {{ args }}

[linux]
switch *args:
    nixos-rebuild switch --flake {{ source_dir() }} {{ args }}

[macos]
rebuild *args:
    darwin-rebuild {{ args }}

[linux]
rebuild *args:
    nixos-rebuild {{ args }}

# update flake inputs
update *inputs:
    nix flake update {{ inputs }}

repl dir='.' file='repl.nix' args="":
    nix repl --verbose --trace-verbose --file {{ dir }}/{{ file }} {{ args }}

[private]
link-flake:
    just link-system-flake
    just link flake.nix ~/.config/home-manager/flake.nix

[macos]
[private]
link-system-flake:
    just link flake.nix /etc/nix-darwin/flake.nix

[linux]
[private]
link-system-flake:
    just link flake.nix /etc/nixos/flake.nix

[macos]
[private]
bootstrap:
    nix run nix-darwin -- switch --flake {{ source_dir() }}
    just link-flake

run app *args:
    nix run .#{{ app }} {{ args }}

@netrc:
    op inject -i netrc.tpl -o ~/.netrc

check: just-check flake-check

[private]
just-check:
    just --check

flake-check:
    env FLAKE_CHECKER_NO_TELEMETRY=true nix run github:DeterminateSystems/flake-checker

[linux]
[macos]
fix-eol:
    rg -g '!windows/*' -l -0 $'\r$' | xargs -0 dos2unix --

[private]
[script]
link path link context=source_dir():
    target="{{ clean(join(context, path)) }}"
    link="{{ clean(link) }}"
    if [ ! -d "$(dirname "$link")" ]; then
      echo "{{ BOLD }}{{ YELLOW }} skipped:{{ RESET }} {{ BLUE }}$(dirname "$link"){{ RESET }} does not exist";
    elif [ "$(readlink -qe "$link")" = "$(readlink -qe "$target")" ]; then
      echo "{{ BOLD }}{{ GREEN }}   found:{{ RESET }} {{ BLUE }}$link{{ RESET }} -> {{ BLUE }}$target{{ RESET }}";
    else
      ln -s -T "$target" "$link";
      echo "{{ BOLD }}{{ GREEN }} created:{{ RESET }} {{ BLUE }}$link{{ RESET }} -> {{ BLUE }}$target{{ RESET }}";
    fi;

fmt: just-fmt nix-fmt

[private]
just-fmt:
    just --fmt

[private]
nix-fmt:
    nix fmt

shell:
    @exec zsh

nix-develop *args:
    nix develop --command zsh {{ args }}

nix-shell *args:
    nix shell --command zsh {{ args }}

git *args:
    git {{ args }}

neogit:
    nvim --cmd "let g:auto_session_enabled = v:false" +Neogit

clickhouse-client-config output=(home_dir() / ".clickhouse-client" / "config.xml"):
    @mkdir -p {{ parent_dir(output) }}
    op inject -i config/clickhouse-client/config.xml -o {{ output }}

[script]
just *args:
    if ! args=$(gum input --prompt="just " --value="{{ args }}" --placeholder="" --header="$(just --list)\n\n"); then
      exit $?
    fi
    echo -e "{{ BOLD }}just $args{{ RESET }}"
    exec just $args

help:
    @just --list --unsorted

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
