#! /usr/bin/env nix

import? 'justfile.local'

#! nix shell nixpkgs#just nixpkgs#gum --command just --justfile
# mod nixos
# mod windows
# mod firewalla

set shell := ["bash", "-e", "-u", "-o", "pipefail", "-c"]
set unstable := true

export XDG_CONFIG_HOME := env('XDG_CONFIG_HOME', home_dir() / ".config")
export FLAKE_CHECKER_NO_TELEMETRY := 'true'

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

help:
    @just --list --unsorted

# Install and activate system flake
[group('nix')]
[macos]
[private]
bootstrap:
    nix run nix-darwin -- switch --flake {{ source_dir() }}
    just link-flake

# Build and activate system flake
[group('nix')]
[macos]
switch *args:
    darwin-rebuild switch --flake {{ source_dir() }} {{ args }}

# Build and activate system flake
[group('nix')]
[linux]
switch *args:
    nixos-rebuild switch --flake {{ source_dir() }} {{ args }}

# Build system flake
[group('nix')]
[macos]
rebuild *args:
    darwin-rebuild {{ args }}

# Build system flake
[group('nix')]
[linux]
rebuild *args:
    nixos-rebuild {{ args }}

[group('nix')]
[macos]
check:
    darwin-rebuild check

# Update flake inputs
[group('nix')]
update *inputs:
    nix flake update --commit-lock-file {{ inputs }}

[group('nix')]
repl dir=source_dir() file='repl.nix' args="":
    nix repl --verbose --trace-verbose --file {{ dir }}/{{ file }} {{ args }}

# Run a nix application
[group('nix')]
[no-cd]
run *args:
    nix run {{ args }}

# Runs an application from nixpkgs
[group('nix')]
[no-cd]
pkg name *args:
    nix run nixpkgs#{{ name }} -- {{ args }}

# Forms an application from flake output attribute `apps.<system>.<name>`
[group('nix')]
[no-cd]
app name *args:
    nix run {{ source_dir() }}#{{ name }} -- {{ args }}

# creates symlink to flake.nix
[group('nix')]
[private]
link-flake: link-system-flake
    just link flake.nix "$XDG_CONFIG_HOME/home-manager/flake.nix"

# creates symlink to flake.nix in /etc/nix-darwin
[group('nix')]
[macos]
[private]
link-system-flake:
    just link flake.nix /etc/nix-darwin/flake.nix

[group('nix')]
[linux]
[private]
link-system-flake:
    just link flake.nix /etc/nixos/flake.nix

[group('nix')]
[private]
nix-fmt:
    nix fmt

[group('nix')]
flake-checker:
    env  nix run github:DeterminateSystems/flake-checker

[group('nix')]
[macos]
nixdctl command *args:
    sudo launchctl {{ command }} systems.determinate.nix-daemon {{ args }}

lint:
    just --fmt --check

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
[private]
fix-eol:
    rg -g '!windows/*' -l -0 $'\r$' | xargs -0 dos2unix --

fmt: just-fmt nix-fmt

[private]
just-fmt:
    just --fmt

shell:
    @exec zsh

[group('nix')]
nix-develop *args:
    nix develop --command zsh {{ args }}

[group('nix')]
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

[positional-arguments]
qmk-shell *args:
    cd "${SRC_HOME:-$HOME/src}/${QMK_FIRMWARE_REPO:-github.com/loganlinn/qmk_firmware}" && nix-shell --quiet "$@"

[positional-arguments]
qmk *args:
    just qmk-shell --command "qmk $*"

qmk-compile keyboard="mode/m256wh" keymap="loganlinn":
    just qmk compile -kb {{ keyboard }} -km {{ keymap }}
