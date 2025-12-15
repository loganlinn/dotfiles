#!/usr/bin/env just --justfile

import? 'justfile.local'

set unstable := true
set shell := ["bash", "-e", "-u", "-o", "pipefail", "-c"]
set positional-arguments := true
set dotenv-load := true

alias S := switch

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

clean:
    fd -u -F result

[group('git')]
@snapshot message="snapshot":
    git stash push --include-untracked --message "{{ message }} [$(date)]" --quiet && \
        git stash apply "stash@{0}" --index --quiet && \
        git rev-parse "stash@{0}"

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
@switch *args:
    sudo -i just rebuild switch "$@"

# Build and activate system flake
[group('nix')]
[linux]
@switch *args:
    sudo nixos-rebuild switch --flake {{ source_dir() }} "$@"

# Build system flake
[group('nix')]
[macos]
[script]
rebuild *args:
    set -eo pipefail
    cmd=(darwin-rebuild --flake "${NIX_DARWIN_FLAKE:-.}" "${@-"--verbose"}")
    echo -e "{{ style("command") }}${cmd[*]}{{ NORMAL }}"
    "${cmd[@]}"
    # "${cmd[@]}" | tee "$0.log"
    # rev=$(just snapshot "darwin-rebuild ${args[*]}")
    # git notes add --allow-empty -F "$0.log" "${rev?}"

# Build system flake
[group('nix')]
[linux]
[script]
rebuild *args:
    set -eo pipefail
    cmd=(nixos-rebuild "$@")
    echo -e "{{ style("command") }}${cmd[*]}{{ NORMAL }}"
    "${cmd[@]}"
    # "${cmd[@]}" | tee "$0.log"
    # rev=$(just snapshot "darwin-rebuild {{ args }}")
    # git notes add --allow-empty -F "$0.log" "${rev?}"

[group('nix')]
[macos]
check: (rebuild "check")

# Update flake inputs
[group('nix')]
update *inputs:
    nix flake update --commit-lock-file {{ inputs }}

# Starts flake repl
[group('nix')]
repl file='./repl.nix':
    nix repl --verbose --trace-verbose --file {{ file }}

# creates symlink to flake.nix
[group('nix')]
[private]
link-flake: link-system-flake
    just link flake.nix "${XDG_CONFIG_HOME-/$HOME/.config}/home-manager/flake.nix"

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
[macos]
nixdctl command *args:
    sudo launchctl {{ command }} systems.determinate.nix-daemon "$@"

lint:
    just --fmt --check

[private]
link-global-justfile:
    @just link justfile "${XDG_CONFIG_HOME-/$HOME/.config}/just/justfile"

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

fmt:
    just --fmt
    nix fmt
    # rg -g '!windows/*' -l -0 $'\r$' | xargs -0 dos2unix --

# Run `nix flake` in dotfiles repo context
[group('nix')]
[positional-arguments]
flake *args:
    nix flake "$@"

# Run `git` in dotfiles repo context
git *args:
    git "$@"

shell:
    @exec zsh

[group('nix')]
develop *args:
    nix develop --command zsh "$@"

@netrc:
    op inject -i netrc.tpl -o ~/.netrc

clickhouse-client-config output=(home_dir() / ".clickhouse-client" / "config.xml"):
    @mkdir -p {{ parent_dir(output) }}
    op inject -i config/clickhouse-client/config.xml -o {{ output }}

clickhouse-connection connection *args:
    wezterm cli set-tab-title "clickhouse://{{ connection }}"
    clickhouse client --connection {{ connection }} "$@"

[script]
run *args:
    if ! args=$(gum input --prompt="just " --value=""$@"" --placeholder="" --header="$(just --list)\n\n"); then
      exit $?
    fi
    echo -e "{{ BOLD }}just $args{{ NORMAL }}"
    exec just $args

qmk-shell *args:
    cd "${SRC_HOME:-$HOME/src}/${QMK_FIRMWARE_REPO:-github.com/loganlinn/qmk_firmware}" && nix-shell --quiet "$@"

qmk *args:
    just qmk-shell --command "qmk $*"

qmk-compile keyboard="mode/m256wh" keymap="loganlinn":
    just qmk compile -kb {{ keyboard }} -km {{ keymap }}

[positional-arguments]
[script]
passage *args:
    hash passage
    if [[ ! -f ${PASSAGE_IDENTITIES_FILE:=$HOME/.passage/identities} ]]; then
      echo "Installing ${PASSAGE_IDENTITIES_FILE} from 1Password..."
      mkdir -p "$(dirname "${PASSAGE_IDENTITIES_FILE}")"
      op document get "passage identities" -o "${PASSAGE_IDENTITIES_FILE}"
      echo "Done."
    fi
    passage "$@"
