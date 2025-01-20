#! /usr/bin/env nix

import? 'justfile.local'

#! nix shell nixpkgs#just nixpkgs#gum --command just --justfile
# mod nixos
# mod windows
# mod firewalla

set shell := ["bash", "-e", "-u", "-o", "pipefail", "-c"]
set unstable := true

export XDG_CONFIG_HOME := env('XDG_CONFIG_HOME', home_dir() / ".config")

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

[macos]
[private]
bootstrap:
    nix run nix-darwin -- switch --flake {{ source_dir() }}
    just link-flake

run app *args:
    nix run .#{{ app }} {{ args }}

check: just-check flake-check

[private]
just-check:
    just --check

flake-check:
    env FLAKE_CHECKER_NO_TELEMETRY=true nix run github:DeterminateSystems/flake-checker

[private]
link-flake:
    just link-system-flake
    just link flake.nix "$XDG_CONFIG_HOME/home-manager/flake.nix"

[macos]
[private]
link-system-flake:
    just link flake.nix /etc/nix-darwin/flake.nix

[linux]
[private]
link-system-flake:
    just link flake.nix /etc/nixos/flake.nix

[private]
link-global-justfile:
    @just link justfile "$XDG_CONFIG_HOME/just/justfile"

[private]
[script]
link path link context=source_dir():
    target="{{ clean(join(context, path)) }}"
    link="{{ clean(link) }}"
    if [ "$(readlink -qe "$link")" = "$(readlink -qe "$target")" ]; then
      echo -e "{{ BOLD }}{{ BLUE }}exists:{{ NORMAL }} {{ CYAN }}$target{{ NORMAL }} <-- {{ BLUE }}$link{{ NORMAL }}";
    else
      echo -e "{{ BOLD }}{{ GREEN }}create:{{ NORMAL }} {{ CYAN }}$target{{ NORMAL }} <-- {{ GREEN }}$link{{ NORMAL }}";
      mkdir -p "$(dirname "$link")";
      ln -s -i -T "$target" "$link";
    fi;

[linux]
[macos]
fix-eol:
    rg -g '!windows/*' -l -0 $'\r$' | xargs -0 dos2unix --

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

@netrc:
    op inject -i netrc.tpl -o ~/.netrc

clickhouse-client-config output=(home_dir() / ".clickhouse-client" / "config.xml"):
    @mkdir -p {{ parent_dir(output) }}
    op inject -i config/clickhouse-client/config.xml -o {{ output }}

clickhouse-connection connection *args:
    wezterm cli set-tab-title "clickhouse://{{ connection }}"
    clickhouse client --connection {{ connection }} {{ args }}

[script]
just *args:
    if ! args=$(gum input --prompt="just " --value="{{ args }}" --placeholder="" --header="$(just --list)\n\n"); then
      exit $?
    fi
    echo -e "{{ BOLD }}just $args{{ NORMAL }}"
    exec just $args

help:
    @just --list --unsorted
