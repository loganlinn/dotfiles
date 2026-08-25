#!/usr/bin/env bats
# shellcheck disable=SC2154 # Bats defines these variables.

setup() {
  WORKMUX_PR="${BATS_TEST_DIRNAME}/../bin/workmux-pr"
  TEST_DIR="${BATS_TEST_TMPDIR}/workmux-pr"
  COMMAND_LOG="$TEST_DIR/commands"
  export COMMAND_LOG

  mkdir -p "$TEST_DIR/bin" "$TEST_DIR/src/github.com/acme/widget"

  cat >"$TEST_DIR/bin/gh" <<'EOF'
#!/bin/sh
printf 'gh' >>"$COMMAND_LOG"
printf ' <%s>' "$@" >>"$COMMAND_LOG"
printf '\n' >>"$COMMAND_LOG"
printf '%s\n' '{"headRepository":{"nameWithOwner":"acme/widget"},"number":42}'
EOF

  cat >"$TEST_DIR/bin/jq" <<'EOF'
#!/bin/sh
cat >/dev/null
printf 'acme/widget\t42\n'
EOF

  cat >"$TEST_DIR/bin/workmux" <<'EOF'
#!/bin/sh
printf 'cwd <%s>\n' "$PWD" >>"$COMMAND_LOG"
printf 'workmux' >>"$COMMAND_LOG"
printf ' <%s>' "$@" >>"$COMMAND_LOG"
printf '\n' >>"$COMMAND_LOG"
EOF

  cat >"$TEST_DIR/bin/pbpaste" <<'EOF'
#!/bin/sh
printf '%s' "$CLIPBOARD"
EOF

  cat >"$TEST_DIR/bin/wl-paste" <<'EOF'
#!/bin/sh
printf 'wl-paste' >>"$COMMAND_LOG"
printf ' <%s>' "$@" >>"$COMMAND_LOG"
printf '\n' >>"$COMMAND_LOG"
printf '%s' "$CLIPBOARD"
EOF

  chmod +x "$TEST_DIR/bin/gh" "$TEST_DIR/bin/jq" \
    "$TEST_DIR/bin/pbpaste" "$TEST_DIR/bin/wl-paste" "$TEST_DIR/bin/workmux"

  PATH="$TEST_DIR/bin:/usr/bin:/bin"
  WORKMUX_PR_SOURCE_ROOT="$TEST_DIR/src"
  PR_URL=https://github.com/acme/widget/pull/42
  CLIPBOARD=$PR_URL
  export CLIPBOARD PATH PR_URL WORKMUX_PR_SOURCE_ROOT
}

@test "resolves a PR and runs workmux from its repository" {
  run "$WORKMUX_PR" https://github.com/acme/widget/pull/42 --branch-name feature

  [ "$status" -eq 0 ]
  grep -Fq 'gh <pr> <view> <https://github.com/acme/widget/pull/42> <--json> <headRepository,number>' "$COMMAND_LOG"
  grep -Fq "cwd <$WORKMUX_PR_SOURCE_ROOT/github.com/acme/widget>" "$COMMAND_LOG"
  grep -Fq 'workmux <add> <-o> <--pr> <42> <--branch-name> <feature>' "$COMMAND_LOG"
}

@test "uses a URL from the macOS clipboard" {
  unset WAYLAND_DISPLAY DISPLAY

  run "$WORKMUX_PR"

  [ "$status" -eq 0 ]
  grep -Fq "gh <pr> <view> <$PR_URL>" "$COMMAND_LOG"
}

@test "uses a URL from the Wayland clipboard" {
  WAYLAND_DISPLAY=wayland-1
  export WAYLAND_DISPLAY

  run "$WORKMUX_PR"

  [ "$status" -eq 0 ]
  grep -Fq 'wl-paste <--no-newline>' "$COMMAND_LOG"
  grep -Fq "gh <pr> <view> <$PR_URL>" "$COMMAND_LOG"
}

@test "rejects clipboard text that is not a URL" {
  CLIPBOARD='acme/widget#42'
  export CLIPBOARD

  run "$WORKMUX_PR"

  [ "$status" -eq 1 ]
  [ "$output" = 'workmux-pr: the clipboard does not contain a URL' ]
  [ ! -e "$COMMAND_LOG" ]
}

@test "fails before PR lookup when a dependency is missing" {
  rm "$TEST_DIR/bin/workmux"

  run "$WORKMUX_PR" "$PR_URL"

  [ "$status" -eq 1 ]
  [ "$output" = 'workmux-pr: required command not found: workmux' ]
  [ ! -e "$COMMAND_LOG" ]
}

@test "prints the repository and command during a dry run" {
  run "$WORKMUX_PR" --dry-run "$PR_URL" --branch-name 'feature name'

  [ "$status" -eq 0 ]
  [ "$output" = "cd $WORKMUX_PR_SOURCE_ROOT/github.com/acme/widget && workmux add -o --pr 42 --branch-name feature\\ name" ]
}
