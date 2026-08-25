#!/usr/bin/env bats
# shellcheck disable=SC2089,SC2090 # JSON is stored in test environment variables.
# shellcheck disable=SC2154 # Bats defines these variables.

bats_require_minimum_version 1.5.0

setup() {
  HERDR_PR="${BATS_TEST_DIRNAME}/../bin/herdr-pr"
  TEST_DIR="${BATS_TEST_TMPDIR}/herdr-pr"
  COMMAND_LOG="$TEST_DIR/commands"
  export COMMAND_LOG

  mkdir -p "$TEST_DIR/bin" "$TEST_DIR/src/github.com/acme/widget/.git"

  cat >"$TEST_DIR/bin/gh" <<'EOF'
#!/bin/sh
printf 'gh' >>"$COMMAND_LOG"
printf ' <%s>' "$@" >>"$COMMAND_LOG"
printf '\n' >>"$COMMAND_LOG"
printf '%s\n' "$PR_JSON"
EOF

  cat >"$TEST_DIR/bin/herdr" <<'EOF'
#!/bin/sh
command_line=herdr
for argument do
  command_line="$command_line <$argument>"
done
printf '%s\n' "$command_line" >>"$COMMAND_LOG"
case " $* " in
  *" worktree list "*)
    if [ "${HERDR_START_REQUIRED:-0}" = 1 ] && [ ! -e "$HERDR_STARTED_FILE" ]; then
      printf '%s\n' '{"id":"cli:worktree:list","error":{"code":"server_not_running","message":"no herdr server is running"}}' >&2
      exit 1
    fi
    printf '%s\n' "$HERDR_WORKTREES_JSON"
    ;;
  *" worktree open "*) printf '{"result":{"type":"worktree_opened","worktree":{"path":"%s"}}}\n' "$WORKTREE_PATH" ;;
  *" worktree create "*) printf '{"result":{"type":"worktree_created","worktree":{"path":"%s"}}}\n' "$WORKTREE_PATH" ;;
  *" server "*) : >"$HERDR_STARTED_FILE" ;;
  *) exit 2 ;;
esac
EOF

  cat >"$TEST_DIR/bin/git" <<'EOF'
#!/bin/sh
printf 'git' >>"$COMMAND_LOG"
printf ' <%s>' "$@" >>"$COMMAND_LOG"
printf '\n' >>"$COMMAND_LOG"
case " $* " in
  *" rev-parse --git-common-dir "*) printf '%s\n' .git ;;
  *" rev-parse refs/herdr-pr/"*) printf '%s\n' "$HEAD_OID" ;;
  *" rev-parse refs/heads/"*) printf '%s\n' "${LOCAL_OID:-$HEAD_OID}" ;;
  *" show-ref --verify --quiet "*) exit "${LOCAL_BRANCH_STATUS:-1}" ;;
  *) exit 0 ;;
esac
EOF

  cat >"$TEST_DIR/bin/kitty" <<'EOF'
#!/bin/sh
printf 'kitty' >>"$COMMAND_LOG"
printf ' <%s>' "$@" >>"$COMMAND_LOG"
printf '\n' >>"$COMMAND_LOG"
case " $* " in
  *" @ ls "*) printf '%s\n' "$KITTY_JSON" ;;
  *" @ launch "*) printf '%s\n' 77 ;;
  *" @ focus-window "*) ;;
  *) exit 2 ;;
esac
EOF

  chmod +x "$TEST_DIR/bin/gh" "$TEST_DIR/bin/git" \
    "$TEST_DIR/bin/herdr" "$TEST_DIR/bin/kitty"

  PATH="$TEST_DIR/bin:$PATH"
  HERDR_PR_SOURCE_ROOT=$(cd "$TEST_DIR/src" && pwd -P)
  HEAD_OID=0123456789abcdef0123456789abcdef01234567
  PR_JSON=$(printf '{"headRefName":"feature/foo","headRefOid":"%s","headRepository":{"name":"widget"},"headRepositoryOwner":{"login":"acme"},"number":42,"url":"https://github.com/base/project/pull/42"}' "$HEAD_OID")
  HERDR_WORKTREES_JSON='{"result":{"type":"worktree_list","worktrees":[]}}'
  HERDR_STARTED_FILE="$TEST_DIR/herdr-started"
  WORKTREE_PATH="$TEST_DIR/work/widget/feature-foo"
  KITTY_JSON='[]'
  export HEAD_OID HERDR_PR_SOURCE_ROOT HERDR_STARTED_FILE \
    HERDR_START_REQUIRED HERDR_WORKTREES_JSON KITTY_JSON \
    LOCAL_BRANCH_STATUS PR_JSON WORKTREE_PATH
}

refute_log() {
  if grep -Fq -- "$1" "$COMMAND_LOG"; then
    printf 'unexpected command log entry: %s\n' "$1" >&2
    return 1
  fi
}

@test "requires one PR argument" {
  run "$HERDR_PR"

  [ "$status" -eq 2 ]
  [ "$output" = "usage: herdr-pr <pr-number-or-url>" ]
}

@test "reuses a checked-out branch and its Herdr workspace" {
  WORKTREE_PATH="$TEST_DIR/existing checkout"
  HERDR_WORKTREES_JSON=$(printf '{"result":{"type":"worktree_list","worktrees":[{"path":"%s","branch":"feature/foo","open_workspace_id":"w2"}]}}' "$WORKTREE_PATH")
  KITTY_JSON='[{"tabs":[{"windows":[{"id":88,"user_vars":{"HERDR":"1","HERDR_SESSION":"acme"}}]}]}]'
  export HERDR_WORKTREES_JSON KITTY_JSON WORKTREE_PATH

  run "$HERDR_PR" 42

  [ "$status" -eq 0 ]
  grep -Fq 'gh <pr> <view> <42> <' "$COMMAND_LOG"
  grep -Fq "herdr <--session> <acme> <worktree> <open> <--cwd> <$HERDR_PR_SOURCE_ROOT/github.com/acme/widget> <--path> <$WORKTREE_PATH> <--label> <widget:feature/foo> <--focus>" "$COMMAND_LOG"
  grep -Fq 'kitty <@> <focus-window> <--match> <id:88>' "$COMMAND_LOG"
  refute_log ' <fetch> '
  refute_log ' <worktree> <create> '
}

@test "creates a worktree at the exact PR commit" {
  LOCAL_BRANCH_STATUS=1
  export LOCAL_BRANCH_STATUS

  run "$HERDR_PR" https://github.com/base/project/pull/42

  [ "$status" -eq 0 ]
  grep -Fq "git <-C> <$HERDR_PR_SOURCE_ROOT/github.com/acme/widget> <fetch> <--no-tags> <https://github.com/base/project.git> <+refs/pull/42/head:refs/herdr-pr/base/project/42>" "$COMMAND_LOG"
  grep -Fq "herdr <--session> <acme> <worktree> <create> <--cwd> <$HERDR_PR_SOURCE_ROOT/github.com/acme/widget> <--branch> <feature/foo> <--base> <refs/herdr-pr/base/project/42> <--label> <widget:feature/foo> <--focus>" "$COMMAND_LOG"
  grep -Fq 'kitty <@> <launch> <--type=os-window> <--os-window-title> <Herdr>' "$COMMAND_LOG"
  grep -Fq '<--var> <HERDR_SESSION=acme> <--> <' "$COMMAND_LOG"
  grep -Fq 'kitty <@> <focus-window> <--match> <id:77>' "$COMMAND_LOG"
}

@test "writes worktree preparation progress to stderr" {
  run --separate-stderr "$HERDR_PR" 42

  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ "$stderr" = "$(printf '%s\n' \
    'herdr-pr: Resolve PR: 42' \
    'herdr-pr: Fetch PR: https://github.com/base/project/pull/42' \
    'herdr-pr: Create worktree: feature/foo' \
    'herdr-pr: Attach Herdr session: acme')" ]
}

@test "prepares the worktree before it attaches to a missing Herdr session" {
  HERDR_START_REQUIRED=1
  export HERDR_START_REQUIRED

  run "$HERDR_PR" 42

  [ "$status" -eq 0 ]
  [ "$(grep -Fc ' <worktree> <list> ' "$COMMAND_LOG")" -ge 2 ]
  grep -Fq 'herdr <--session> <acme> <server>' "$COMMAND_LOG"
  grep -Fq 'kitty <@> <launch> <--type=os-window>' "$COMMAND_LOG"
  grep -Fq '<session> <attach> <acme>' "$COMMAND_LOG"
  [[ $output != *server_not_running* ]]

  server_line=$(grep -nF 'herdr <--session> <acme> <server>' "$COMMAND_LOG")
  server_line=${server_line%%:*}
  create_line=$(grep -nF ' <worktree> <create> ' "$COMMAND_LOG")
  create_line=${create_line%%:*}
  attach_line=$(grep -nF '<session> <attach> <acme>' "$COMMAND_LOG")
  attach_line=${attach_line%%:*}
  [ "$server_line" -lt "$create_line" ]
  [ "$create_line" -lt "$attach_line" ]
}

@test "opens a new tab in the dedicated Herdr OS window" {
  KITTY_JSON='[{"tabs":[{"windows":[{"id":51,"user_vars":{"HERDR":"1","HERDR_SESSION":"other"}}]}]}]'
  export KITTY_JSON

  run "$HERDR_PR" 42

  [ "$status" -eq 0 ]
  grep -Fq 'kitty <@> <launch> <--type=tab> <--match> <window_id:51>' "$COMMAND_LOG"
  refute_log '<--type=os-window>'
}

@test "fast-forwards an unused local PR branch" {
  LOCAL_BRANCH_STATUS=0
  LOCAL_OID=1111111111111111111111111111111111111111
  export LOCAL_BRANCH_STATUS LOCAL_OID

  run "$HERDR_PR" 42

  [ "$status" -eq 0 ]
  grep -Fq "git <-C> <$HERDR_PR_SOURCE_ROOT/github.com/acme/widget> <merge-base> <--is-ancestor> <$LOCAL_OID> <$HEAD_OID>" "$COMMAND_LOG"
  grep -Fq "git <-C> <$HERDR_PR_SOURCE_ROOT/github.com/acme/widget> <update-ref> <refs/heads/feature/foo> <$HEAD_OID> <$LOCAL_OID>" "$COMMAND_LOG"
}

@test "does not overwrite a divergent local PR branch" {
  LOCAL_BRANCH_STATUS=0
  LOCAL_OID=1111111111111111111111111111111111111111
  export LOCAL_BRANCH_STATUS LOCAL_OID
  export GIT_DIVERGED=1

  cat >"$TEST_DIR/bin/git" <<'EOF'
#!/bin/sh
printf 'git' >>"$COMMAND_LOG"
printf ' <%s>' "$@" >>"$COMMAND_LOG"
printf '\n' >>"$COMMAND_LOG"
case " $* " in
  *" rev-parse --git-common-dir "*) printf '%s\n' .git ;;
  *" rev-parse refs/herdr-pr/"*) printf '%s\n' "$HEAD_OID" ;;
  *" rev-parse refs/heads/"*) printf '%s\n' "$LOCAL_OID" ;;
  *" show-ref --verify --quiet "*) exit 0 ;;
  *" merge-base --is-ancestor "*) exit 1 ;;
  *) exit 0 ;;
esac
EOF
  chmod +x "$TEST_DIR/bin/git"

  run "$HERDR_PR" 42

  [ "$status" -eq 1 ]
  [[ $output == *"herdr-pr: local branch differs from the PR: feature/foo"* ]]
  refute_log ' <update-ref> '
  refute_log ' <worktree> <create> '
}

@test "explains how to clone a missing head repository" {
  rm -rf "$TEST_DIR/src/github.com/acme/widget"

  run "$HERDR_PR" 42

  [ "$status" -eq 1 ]
  [[ $output == *"herdr-pr: repository not found: $HERDR_PR_SOURCE_ROOT/github.com/acme/widget"* ]]
  [[ $output == *"Run: ghq get https://github.com/acme/widget"* ]]
  refute_log 'herdr '
}

@test "rejects a PR without a head repository" {
  PR_JSON='{"headRefName":"feature/foo","headRefOid":"0123456789abcdef0123456789abcdef01234567","headRepository":null,"headRepositoryOwner":null,"number":42,"url":"https://github.com/base/project/pull/42"}'
  export PR_JSON

  run "$HERDR_PR" 42

  [ "$status" -eq 1 ]
  [[ $output == *"herdr-pr: the PR has no usable head repository"* ]]
  refute_log 'herdr '
}
