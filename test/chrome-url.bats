#!/usr/bin/env bats
# shellcheck disable=SC2154 # Bats defines these variables.

setup() {
  CHROME_URL="${BATS_TEST_DIRNAME}/../bin/chrome-url"
  TEST_DIR="${BATS_TEST_TMPDIR}/chrome-url"
  CLIPBOARD_FILE="$TEST_DIR/clipboard"
  OSASCRIPT_MARKER="$TEST_DIR/osascript-called"
  export CLIPBOARD_FILE OSASCRIPT_MARKER

  mkdir -p "$TEST_DIR/bin" "$TEST_DIR/work"

  cat >"$TEST_DIR/bin/uname" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${FAKE_UNAME:-Darwin}"
EOF

  cat >"$TEST_DIR/bin/osascript" <<'EOF'
#!/usr/bin/env bash
: >"$OSASCRIPT_MARKER"
printf '%s\n' 'https://example.com/a?b=c&d=e'
EOF

  cat >"$TEST_DIR/bin/pbcopy" <<'EOF'
#!/usr/bin/env bash
cat >"$CLIPBOARD_FILE"
EOF

  chmod +x "$TEST_DIR/bin/osascript" "$TEST_DIR/bin/pbcopy" "$TEST_DIR/bin/uname"
  PATH="$TEST_DIR/bin:/usr/bin:/bin"
  export PATH
}

@test "prints the URL by default" {
  cd "$TEST_DIR/work"

  run "$CHROME_URL"

  [ "$status" -eq 0 ]
  [ "$output" = 'https://example.com/a?b=c&d=e' ]
  [ ! -e "$CLIPBOARD_FILE" ]
}

@test "copies the URL with the short clipboard flag" {
  cd "$TEST_DIR/work"

  run "$CHROME_URL" -c

  [ "$status" -eq 0 ]
  [ "$output" = 'https://example.com/a?b=c&d=e' ]
  [ "$(cat "$CLIPBOARD_FILE")" = 'https://example.com/a?b=c&d=e' ]
}

@test "copies without output with the long flags" {
  run "$CHROME_URL" --clipboard --quiet

  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ "$(cat "$CLIPBOARD_FILE")" = 'https://example.com/a?b=c&d=e' ]
}

@test "does not print the URL with the short quiet flag" {
  run "$CHROME_URL" -q

  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -e "$CLIPBOARD_FILE" ]
}

@test "rejects non-Darwin systems before it calls osascript" {
  run env FAKE_UNAME=Linux "$CHROME_URL"

  [ "$status" -eq 1 ]
  [ "$output" = 'chrome-url: unsupported operating system: Linux' ]
  [ ! -e "$OSASCRIPT_MARKER" ]
}

@test "rejects unknown arguments" {
  run "$CHROME_URL" --invalid

  [ "$status" -eq 2 ]
  [ "$output" = 'Usage: chrome-url [-c|--clipboard] [-q|--quiet]' ]
  [ ! -e "$OSASCRIPT_MARKER" ]
}
