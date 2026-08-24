#!/usr/bin/env bats

setup() {
  KITTY_DASHBOARD="${BATS_TEST_DIRNAME}/../bin/kitty-dashboard"
  TEST_DIR="${BATS_TEST_TMPDIR}/kitty-dashboard"
  ARGS_FILE="$TEST_DIR/kitten-args"
  export ARGS_FILE

  # The script prepends $HOME/.local/bin to PATH, so a stub there wins over
  # the real kitten. It records argv up to the `sh` wrapper, then runs the
  # wrapper for real so the exec'd command output lands in the log.
  mkdir -p "$TEST_DIR/home/.local/bin"
  cat >"$TEST_DIR/home/.local/bin/kitten" <<'EOF'
#!/bin/sh
: >"$ARGS_FILE.tmp"
i=0
for a in "$@"; do
  i=$((i + 1))
  [ "$a" = sh ] && break
  printf '%s\n' "$a" >>"$ARGS_FILE.tmp"
done
mv "$ARGS_FILE.tmp" "$ARGS_FILE"
shift $((i - 1))
exec "$@"
EOF
  chmod +x "$TEST_DIR/home/.local/bin/kitten"

  export HOME="$TEST_DIR/home"
  export KITTY_DASHBOARD_LOG="$TEST_DIR/log"
  export KITTY_LISTEN_ON="unix:/fake/kitty.sock"
  unset KITTY_DASHBOARD_GROUP
}

# The script backgrounds kitten, so poll for the stub's side effects.
wait_for() {
  local i
  for i in $(seq 1 50); do
    [[ -s $1 ]] && return 0
    sleep 0.1
  done
  echo >&2 "timed out waiting for $1"
  return 1
}

wait_for_args() { wait_for "$ARGS_FILE"; }
# The stub writes ARGS_FILE before it execs the command, so a non-empty log
# implies ARGS_FILE is complete too.
wait_for_log() { wait_for "$KITTY_DASHBOARD_LOG"; }

arg_after() {
  grep -A1 -x -- "$1" "$ARGS_FILE" | tail -n1
}

@test "fails with usage when no command is given" {
  run "$KITTY_DASHBOARD"

  [ "$status" -eq 2 ]
  [[ $output == "usage: kitty-dashboard"* ]]
}

@test "fails with usage when only -- is given" {
  run "$KITTY_DASHBOARD" --edge top --

  [ "$status" -eq 2 ]
}

@test "runs the command after -- and derives the instance group from it" {
  "$KITTY_DASHBOARD" -- sh -c 'echo "ran:$0:$1"' gh dash
  wait_for_log

  [ "$(arg_after --instance-group)" = "sh-c-echo-ran-0-1-gh-dash" ]
  [ "$(cat "$KITTY_DASHBOARD_LOG")" = "ran:gh:dash" ]
}

@test "treats all args as the command when -- is absent" {
  "$KITTY_DASHBOARD" sh -c 'echo no-dashes'
  wait_for_log

  [ "$(arg_after --instance-group)" = "sh-c-echo-no-dashes" ]
  [ "$(cat "$KITTY_DASHBOARD_LOG")" = "no-dashes" ]
}

@test "preserves command argv with spaces" {
  "$KITTY_DASHBOARD" -- sh -c 'printf "[%s]" "$@"' sh a "b c"
  wait_for_log

  [ "$(cat "$KITTY_DASHBOARD_LOG")" = "[a][b c]" ]
}

@test "passes panel flags before -- after the defaults so they override" {
  "$KITTY_DASHBOARD" --edge top --lines 20 -- true
  wait_for_args

  # defaults first
  [ "$(grep -c -x -- --edge "$ARGS_FILE")" -eq 2 ]
  # user flag is last
  [ "$(grep -A1 -x -- --edge "$ARGS_FILE" | tail -n1)" = "top" ]
  [ "$(grep -A1 -x -- --lines "$ARGS_FILE" | tail -n1)" = "20" ]
}

@test "KITTY_DASHBOARD_GROUP overrides the derived instance group" {
  KITTY_DASHBOARD_GROUP=custom "$KITTY_DASHBOARD" -- true
  wait_for_args

  [ "$(arg_after --instance-group)" = "custom" ]
}

@test "truncates long derived instance groups to 32 chars" {
  "$KITTY_DASHBOARD" -- /opt/homebrew/bin/gh extension exec dash
  wait_for_args

  [ "$(arg_after --instance-group)" = "opt-homebrew-bin-gh-extension-ex" ]
}

@test "restores KITTY_LISTEN_ON of the main instance inside the panel" {
  "$KITTY_DASHBOARD" -- sh -c 'echo "$KITTY_LISTEN_ON"'
  wait_for_log

  [ "$(cat "$KITTY_DASHBOARD_LOG")" = "unix:/fake/kitty.sock" ]
}

@test "env overrides edge, lines, and columns" {
  KITTY_DASHBOARD_EDGE=bottom KITTY_DASHBOARD_LINES=10 KITTY_DASHBOARD_COLUMNS=80 \
    "$KITTY_DASHBOARD" -- true
  wait_for_args

  [ "$(arg_after --edge)" = "bottom" ]
  [ "$(arg_after --lines)" = "10" ]
  [ "$(arg_after --columns)" = "80" ]
}

@test "-C runs the command from the given directory" {
  mkdir -p "$TEST_DIR/repo"
  local expected
  expected=$(cd "$TEST_DIR/repo" && pwd -P)

  "$KITTY_DASHBOARD" -C "$TEST_DIR/repo" -- sh -c 'pwd -P'
  wait_for_log

  [ "$(cat "$KITTY_DASHBOARD_LOG")" = "$expected" ]
}

@test "--chdir and --chdir= work and may follow panel flags" {
  mkdir -p "$TEST_DIR/repo"
  local expected
  expected=$(cd "$TEST_DIR/repo" && pwd -P)

  "$KITTY_DASHBOARD" --edge top --chdir "$TEST_DIR/repo" -- sh -c 'pwd -P'
  wait_for_log
  [ "$(cat "$KITTY_DASHBOARD_LOG")" = "$expected" ]
  [ "$(arg_after --edge)" = "top" ]

  rm "$KITTY_DASHBOARD_LOG"
  "$KITTY_DASHBOARD" "--chdir=$TEST_DIR/repo" -- sh -c 'pwd -P'
  wait_for_log
  [ "$(cat "$KITTY_DASHBOARD_LOG")" = "$expected" ]
}

@test "-C works without -- (rest is the command)" {
  mkdir -p "$TEST_DIR/repo"

  "$KITTY_DASHBOARD" -C "$TEST_DIR/repo" sh -c 'echo "in:$(basename "$(pwd)")"'
  wait_for_log

  [ "$(cat "$KITTY_DASHBOARD_LOG")" = "in:repo" ]
}

@test "-C adds a directory checksum to the instance group" {
  mkdir -p "$TEST_DIR/a" "$TEST_DIR/b"

  "$KITTY_DASHBOARD" -C "$TEST_DIR/a" -- true
  wait_for_args
  local group_a group_a_slash group_b
  group_a=$(arg_after --instance-group)

  rm "$ARGS_FILE"
  "$KITTY_DASHBOARD" -C "$TEST_DIR/a/" -- true
  wait_for_args
  group_a_slash=$(arg_after --instance-group)

  rm "$ARGS_FILE"
  "$KITTY_DASHBOARD" -C "$TEST_DIR/b" -- true
  wait_for_args
  group_b=$(arg_after --instance-group)

  [[ $group_a =~ ^true-[0-9]+$ ]]
  [ "$group_a" = "$group_a_slash" ]
  [ "$group_a" != "$group_b" ]
  [ "${#group_b}" -le 32 ]
}

@test "-C with a long command keeps the group within 32 chars" {
  mkdir -p "$TEST_DIR/repo"

  "$KITTY_DASHBOARD" -C "$TEST_DIR/repo" -- /opt/homebrew/bin/gh extension exec dash
  wait_for_args

  local group
  group=$(arg_after --instance-group)
  [[ $group =~ ^opt-homebrew-bin-gh-e-[0-9]+$ ]]
  [ "${#group}" -le 32 ]
}

@test "-C fails early on a missing directory" {
  run "$KITTY_DASHBOARD" -C "$TEST_DIR/nope" -- true

  [ "$status" -eq 1 ]
  [[ $output == *"not a directory: $TEST_DIR/nope" ]]
  [ ! -e "$ARGS_FILE" ]
}

@test "-C without a value shows usage" {
  run "$KITTY_DASHBOARD" -C

  [ "$status" -eq 2 ]
  [[ $output == "usage: kitty-dashboard"* ]]
}
