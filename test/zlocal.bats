#!/usr/bin/env bats

setup() {
  export TEST_ROOT="$BATS_TEST_TMPDIR/home with spaces"
  export COMMAND_LOG="$BATS_TEST_TMPDIR/gh.args"
  export EDIT_CONTENT='ZLOCAL_SOURCED=edited'
  mkdir -p "$TEST_ROOT" "$BATS_TEST_TMPDIR/bin"
  CLI="$BATS_TEST_TMPDIR/zlocal"
  # Relocate file access so the tests cannot edit the real startup files.
  sed 's|\$HOME/|$TEST_ROOT/|g' "$BATS_TEST_DIRNAME/../config/zsh/functions/zlocal" > "$CLI"
  for name in zshrc zshenv zprofile; do
    printf 'ZLOCAL_SOURCED=%s\n' "$name" > "$TEST_ROOT/.$name.local"
  done
  cat > "$BATS_TEST_TMPDIR/bin/gh" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$COMMAND_LOG"
if [ "${UPLOAD_STATUS:-0}" != 0 ]; then
  echo 'upload failed' >&2
  exit "$UPLOAD_STATUS"
fi
EOF
  cat > "$BATS_TEST_TMPDIR/bin/vipe" <<'EOF'
#!/bin/sh
cat >/dev/null
printf '%s\n' "$EDIT_CONTENT"
EOF
  cat > "$BATS_TEST_TMPDIR/bin/delta" <<'EOF'
#!/bin/sh
cat
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/"*
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

run_zlocal() {
  run zsh -dfc '
    autoload -Uz "$1"
    shift
    zlocal "$@"
    rc=$?
    print -r -- "loaded=${ZLOCAL_SOURCED-}"
    exit $rc
  ' _ "$CLI" "$@"
}

assert_upload() {
  printf '%s\n' api gists/90b892b5069e95c2f893fab46177334a \
    --method PATCH --field "files[.$1.local][content]=@$TEST_ROOT/.$1.local" \
    --silent > "$BATS_TEST_TMPDIR/expected.args"
  cmp "$BATS_TEST_TMPDIR/expected.args" "$COMMAND_LOG"
}

@test "default edit saves, uploads and sources zshrc only" {
  run_zlocal
  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_ROOT/.zshrc.local")" = "$EDIT_CONTENT" ]
  [ "$(cat "$TEST_ROOT/.zshenv.local")" = ZLOCAL_SOURCED=zshenv ]
  [[ "$output" == *'loaded=edited'* ]]
  assert_upload zshrc
}

@test "all selectors upload their own filename without editing or sourcing" {
  for name in zshrc zshenv zprofile; do
    for selector in "$name" "$name.local" ".$name.local"; do
      run_zlocal --push "$selector"
      [ "$status" -eq 0 ]
      [[ "$output" != *'editing '* ]]
      [[ "$output" != *'sourced: '* ]]
      assert_upload "$name"
    done
  done
  run_zlocal zprofile --push
  [ "$status" -eq 0 ]
  assert_upload zprofile
}

@test "selected edit can create a missing startup file" {
  rm "$TEST_ROOT/.zshenv.local"
  run_zlocal .zshenv.local
  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_ROOT/.zshenv.local")" = "$EDIT_CONTENT" ]
  [[ "$output" == *'loaded=edited'* ]]
  assert_upload zshenv
}

@test "invalid selection and syntax cannot change files or upload" {
  run_zlocal ../outside
  [ "$status" -eq 2 ]
  run_zlocal zshenv zprofile
  [ "$status" -eq 2 ]
  export EDIT_CONTENT='if then'
  run_zlocal zshenv
  [ "$status" -ne 0 ]
  [ "$(cat "$TEST_ROOT/.zshenv.local")" = ZLOCAL_SOURCED=zshenv ]
  [ ! -e "$COMMAND_LOG" ]
}

@test "unchanged edits do not upload" {
  export EDIT_CONTENT=ZLOCAL_SOURCED=zprofile
  run_zlocal zprofile
  [ "$status" -eq 0 ]
  [[ "$output" == *'no changes detected'* ]]
  [ ! -e "$COMMAND_LOG" ]
}

@test "upload failures propagate without losing a valid local edit" {
  export UPLOAD_STATUS=7
  run_zlocal --push
  [ "$status" -eq 7 ]
  [[ "$output" != *'updated: '* ]]
  run_zlocal zprofile
  [ "$status" -eq 7 ]
  [ "$(cat "$TEST_ROOT/.zprofile.local")" = "$EDIT_CONTENT" ]
  [[ "$output" == *'loaded=edited'* ]]
  [[ "$output" != *'updated: '* ]]
}
