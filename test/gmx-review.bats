#!/usr/bin/env bats
# shellcheck disable=SC2016 # Skill names and shell snippets are literal test data.
# shellcheck disable=SC2154 # Bats defines these variables.

setup() {
  CLI="$BATS_TEST_TMPDIR/gmx-review"
  export TEST_ROOT="$BATS_TEST_TMPDIR/fixture"
  # Relocate only clone lookup so tests never write into the real home directory.
  sed 's|$HOME/src/github.com|$TEST_ROOT/src/github.com|g' \
    "$BATS_TEST_DIRNAME/../bin/gmx-review" >"$CLI"
  chmod +x "$CLI"
  export COMMAND_LOG="$BATS_TEST_TMPDIR/commands"
  export WORKTREE="$TEST_ROOT/review worktree"
  mkdir -p "$TEST_ROOT/bin" "$TEST_ROOT/src/github.com/acme/project" "$WORKTREE"
  unset KITTY_WINDOW_ID
  cat >"$TEST_ROOT/bin/gh" <<'EOF'
#!/bin/bash
if [[ $1 == pr ]]; then
  printf '%s' "$3" >"$COMMAND_LOG.pr"
  printf 'feature/review\thttps://github.com/acme/project/pull/42\n'
else
  echo acme/project
fi
EOF
  cat >"$TEST_ROOT/bin/gmx" <<'EOF'
#!/bin/bash
case $1 in
  get) printf '%s\n' "$WORKTREE" ;;
  rm) printf '%s\n' "$@" >"$COMMAND_LOG.rm"; exit "${REMOVE_STATUS:-0}" ;;
  *) exit 99 ;;
esac
EOF
  cat >"$TEST_ROOT/bin/codex" <<'EOF'
#!/bin/bash
printf '%s\0' "$@" >"$COMMAND_LOG.codex"
pwd >"$COMMAND_LOG.cwd"
if [[ ${REQUIRE_TTY:-0} == 1 && ! -t 0 ]]; then exit 99; fi
exit "${CODEX_STATUS:-0}"
EOF
  cat >"$TEST_ROOT/bin/pbpaste" <<'EOF'
#!/bin/bash
echo 42
EOF
  chmod +x "$TEST_ROOT/bin/"*
  export PATH="$TEST_ROOT/bin:$PATH"
}

assert_codex_args() {
  printf '%s\0' "$@" >"$COMMAND_LOG.expected"
  cmp "$COMMAND_LOG.expected" "$COMMAND_LOG.codex"
  [ "$(cat "$COMMAND_LOG.cwd")" = "$WORKTREE" ]
  [ "$(tail -n 1 "$COMMAND_LOG.rm")" = "$WORKTREE" ]
}

@test "clipboard default starts the review skill" {
  run "$CLI"
  [ "$status" -eq 0 ]
  [ "$(cat "$COMMAND_LOG.pr")" = 42 ]
  assert_codex_args -- '$review-agent'
}

@test "stdin resolves the PR and preserves extra prompt instructions literally" {
  run bash -c 'printf "%s\n" https://github.com/acme/project/pull/42 | "$@"' _ \
    "$CLI" - 'Focus on $(touch nope), $variables, and "quotes".'
  [ "$status" -eq 0 ]
  [ "$(cat "$COMMAND_LOG.pr")" = https://github.com/acme/project/pull/42 ]
  assert_codex_args $'$review-agent\n\nFocus on $(touch nope), $variables, and "quotes".'
}

@test "options and their values are preserved before and after the prompt" {
  run "$CLI" 42 --model review -c 'model_reasoning_effort="high"' --search \
    'Focus on retries' --no-alt-screen
  [ "$status" -eq 0 ]
  assert_codex_args --model review -c 'model_reasoning_effort="high"' --search \
    $'$review-agent\n\nFocus on retries' --no-alt-screen
}

@test "piped PR input reconnects Codex to the controlling terminal" {
  export REQUIRE_TTY=1
  run script -q /dev/null bash -c 'printf "42\n" | "$1" - "Focus on stdin"' _ "$CLI"
  [ "$status" -eq 0 ]
  assert_codex_args $'$review-agent\n\nFocus on stdin'
}

@test "attached option values and options without a prompt work" {
  run "$CLI" 42 --model=example -pwork --no-alt-screen
  [ "$status" -eq 0 ]
  assert_codex_args --model=example -pwork --no-alt-screen -- '$review-agent'
}

@test "subcommands and aliases pass through unchanged" {
  for cmd in exec e resume review; do
    run "$CLI" 42 -c 'key="value"' "$cmd" --help
    [ "$status" -eq 0 ]
    assert_codex_args -c 'key="value"' "$cmd" --help
  done
}

@test "delimiter permits command names and leading dashes as prompts" {
  for prompt in exec --check; do
    run "$CLI" 42 -- "$prompt"
    [ "$status" -eq 0 ]
    assert_codex_args -- "\$review-agent"$'\n\n'"$prompt"
  done
}

@test "empty delimiter still supplies the default prompt" {
  run "$CLI" 42 --
  [ "$status" -eq 0 ]
  assert_codex_args -- '$review-agent'
}

@test "variadic images are not mistaken for a prompt" {
  run "$CLI" 42 --image 'first image.png' second.png
  [ "$status" -eq 0 ]
  assert_codex_args --image 'first image.png' second.png -- '$review-agent'

  run "$CLI" 42 -ifirst.png second.png -- 'Inspect screenshots'
  [ "$status" -eq 0 ]
  assert_codex_args -ifirst.png second.png -- $'$review-agent\n\nInspect screenshots'
}

@test "empty stdin and missing option values fail before creating a worktree" {
  run bash -c '"$@" </dev/null' _ "$CLI" -
  [ "$status" -ne 0 ]
  [ ! -e "$COMMAND_LOG.codex" ]
  run "$CLI" 42 --model
  [ "$status" -ne 0 ]
  [ ! -e "$COMMAND_LOG.pr" ]
}

@test "Codex failure still cleans up and takes precedence over removal failure" {
  export CODEX_STATUS=7 REMOVE_STATUS=8
  run "$CLI" 42 'Focus on errors'
  [ "$status" -eq 7 ]
  assert_codex_args $'$review-agent\n\nFocus on errors'
}
