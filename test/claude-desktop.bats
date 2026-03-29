#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  SCRIPT="$DIR/../bin/claude-desktop"

  # Temp dir for mock binaries and captured URLs
  TEST_TMPDIR="$(mktemp -d)"
  export URL_CAPTURE_FILE="$TEST_TMPDIR/opened_url"

  # Create a mock `open` (macOS) and `xdg-open` (Linux) that capture the URL
  cat >"$TEST_TMPDIR/open" <<'MOCK'
#!/usr/bin/env bash
printf '%s' "$1" >"$URL_CAPTURE_FILE"
MOCK
  chmod +x "$TEST_TMPDIR/open"
  cp "$TEST_TMPDIR/open" "$TEST_TMPDIR/xdg-open"

  # Prepend mock bin dir so script picks up our stubs
  export PATH="$TEST_TMPDIR:$PATH"
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}

# Helper: run script and return the URL that was opened
opened_url() {
  cat "$URL_CAPTURE_FILE"
}

# Source script functions without running main.
# CLAUDE_DESKTOP_SOURCED=1 prevents the trailing `main "$@"` from executing.
source_functions() {
  CLAUDE_DESKTOP_SOURCED=1 source "$SCRIPT"  # shellcheck disable=SC1090
}

# --------------------------------------------------------------------------- #
# urlencode
# --------------------------------------------------------------------------- #

@test "urlencode: safe chars pass through unchanged" {
  source_functions
  run urlencode "hello-world_foo.bar~baz"
  assert_success
  assert_output "hello-world_foo.bar~baz"
}

@test "urlencode: spaces become %20" {
  source_functions
  run urlencode "hello world"
  assert_success
  assert_output "hello%20world"
}

@test "urlencode: special chars are percent-encoded" {
  source_functions
  run urlencode "a&b=c+d"
  assert_success
  assert_output "a%26b%3Dc%2Bd"
}

@test "urlencode: empty string produces empty output" {
  source_functions
  run urlencode ""
  assert_success
  assert_output ""
}

@test "urlencode: slash is encoded" {
  source_functions
  run urlencode "foo/bar"
  assert_success
  assert_output "foo%2Fbar"
}

@test "urlencode: question mark is encoded" {
  source_functions
  run urlencode "foo?bar"
  assert_success
  assert_output "foo%3Fbar"
}

# --------------------------------------------------------------------------- #
# is_uuid
# --------------------------------------------------------------------------- #

@test "is_uuid: valid lowercase UUID returns true" {
  source_functions
  run is_uuid "550e8400-e29b-41d4-a716-446655440000"
  assert_success
}

@test "is_uuid: uppercase UUID returns false" {
  source_functions
  run is_uuid "550E8400-E29B-41D4-A716-446655440000"
  assert_failure
}

@test "is_uuid: random string returns false" {
  source_functions
  run is_uuid "not-a-uuid"
  assert_failure
}

@test "is_uuid: empty string returns false" {
  source_functions
  run is_uuid ""
  assert_failure
}

@test "is_uuid: UUID missing a segment returns false" {
  source_functions
  run is_uuid "550e8400-e29b-41d4-a716"
  assert_failure
}

@test "is_uuid: UUID with extra chars returns false" {
  source_functions
  run is_uuid "550e8400-e29b-41d4-a716-446655440000x"
  assert_failure
}

# --------------------------------------------------------------------------- #
# normalize_url
# --------------------------------------------------------------------------- #

@test "normalize_url: https://claude.ai URL" {
  source_functions
  run normalize_url "https://claude.ai/chat/abc"
  assert_success
  assert_output "claude://claude.ai/chat/abc"
}

@test "normalize_url: claude:// URL passes through" {
  source_functions
  run normalize_url "claude://claude.ai/recents"
  assert_success
  assert_output "claude://claude.ai/recents"
}

@test "normalize_url: claude.ai/ prefix" {
  source_functions
  run normalize_url "claude.ai/settings"
  assert_success
  assert_output "claude://claude.ai/settings"
}

@test "normalize_url: /claude.ai/ prefix" {
  source_functions
  run normalize_url "/claude.ai/settings"
  assert_success
  assert_output "claude://claude.ai/settings"
}

@test "normalize_url: bare path gets claude.ai host" {
  source_functions
  run normalize_url "chat/some-id"
  assert_success
  assert_output "claude://claude.ai/chat/some-id"
}

@test "normalize_url: strips leading whitespace" {
  source_functions
  run normalize_url "  claude://claude.ai/new"
  assert_success
  assert_output "claude://claude.ai/new"
}

# --------------------------------------------------------------------------- #
# open command (integration)
# --------------------------------------------------------------------------- #

@test "open: https://claude.ai URL" {
  run "$SCRIPT" open "https://claude.ai/chat/abc"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/chat/abc"
}

@test "open: claude:// URL passes through" {
  run "$SCRIPT" open "claude://claude.ai/recents"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/recents"
}

@test "open: bare path" {
  run "$SCRIPT" open "chat/foo"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/chat/foo"
}

@test "open: URL fallback routing (https:// first arg)" {
  run "$SCRIPT" "https://claude.ai/settings"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/settings"
}

@test "open: URL fallback routing (claude:// first arg)" {
  run "$SCRIPT" "claude://claude.ai/recents"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/recents"
}

@test "open: URL fallback routing (claude.ai/ first arg)" {
  run "$SCRIPT" "claude.ai/customize"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/customize"
}

@test "open: URL fallback routing (/claude.ai/ first arg)" {
  run "$SCRIPT" "/claude.ai/logout"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/logout"
}

# --------------------------------------------------------------------------- #
# new command
# --------------------------------------------------------------------------- #

@test "new: no args opens new without q param" {
  run "$SCRIPT" new
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/new"
}

@test "new: positional prompt is URL-encoded" {
  run "$SCRIPT" new "hello world"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/new?q=hello%20world"
}

@test "new: -q flag" {
  run "$SCRIPT" new -q "my query"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/new?q=my%20query"
}

@test "new: --query flag" {
  run "$SCRIPT" new --query "my query"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/new?q=my%20query"
}

@test "new: -q - reads from stdin" {
  run bash -c "printf 'stdin prompt' | '$SCRIPT' new -q -"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/new?q=stdin%20prompt"
}

# --------------------------------------------------------------------------- #
# chat command
# --------------------------------------------------------------------------- #

@test "chat: valid UUID" {
  run "$SCRIPT" chat "550e8400-e29b-41d4-a716-446655440000"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/chat/550e8400-e29b-41d4-a716-446655440000"
}

@test "chat: invalid UUID fails" {
  run "$SCRIPT" chat "not-a-uuid"
  assert_failure
  assert_output --partial "Invalid conversation UUID"
}

@test "chat: missing UUID fails" {
  run "$SCRIPT" chat
  assert_failure
}

# --------------------------------------------------------------------------- #
# project command
# --------------------------------------------------------------------------- #

@test "project: valid UUID" {
  run "$SCRIPT" project "550e8400-e29b-41d4-a716-446655440000"
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/project/550e8400-e29b-41d4-a716-446655440000"
}

@test "project: invalid UUID fails" {
  run "$SCRIPT" project "bad-id"
  assert_failure
  assert_output --partial "Invalid project UUID"
}

@test "project: missing UUID fails" {
  run "$SCRIPT" project
  assert_failure
}

# --------------------------------------------------------------------------- #
# recents command
# --------------------------------------------------------------------------- #

@test "recents: opens correct URL" {
  run "$SCRIPT" recents
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/recents"
}

# --------------------------------------------------------------------------- #
# code command
# --------------------------------------------------------------------------- #

@test "code: opens claude-code-desktop" {
  run "$SCRIPT" code
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/claude-code-desktop"
}

@test "code scheduled: opens scheduled URL" {
  run "$SCRIPT" code scheduled
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/claude-code-desktop/scheduled"
}

@test "code: unknown subcommand fails" {
  run "$SCRIPT" code unknown
  assert_failure
  assert_output --partial "Unknown subcommand: unknown"
}

# --------------------------------------------------------------------------- #
# cowork command
# --------------------------------------------------------------------------- #

@test "cowork: no args opens bare cowork URL" {
  run "$SCRIPT" cowork
  assert_success
  assert_equal "$(opened_url)" "claude://cowork/new"
}

@test "cowork: prompt only" {
  run "$SCRIPT" cowork "hello world"
  assert_success
  assert_equal "$(opened_url)" "claude://cowork/new?q=hello%20world"
}

@test "cowork: -q flag" {
  run "$SCRIPT" cowork -q "my prompt"
  assert_success
  assert_equal "$(opened_url)" "claude://cowork/new?q=my%20prompt"
}

@test "cowork: single -f flag" {
  run "$SCRIPT" cowork -f "/path/to/file.txt"
  assert_success
  assert_equal "$(opened_url)" "claude://cowork/new?file=%2Fpath%2Fto%2Ffile.txt"
}

@test "cowork: single -d flag" {
  run "$SCRIPT" cowork -d "/my/folder"
  assert_success
  assert_equal "$(opened_url)" "claude://cowork/new?folder=%2Fmy%2Ffolder"
}

@test "cowork: prompt with file and folder" {
  run "$SCRIPT" cowork "prompt" -f "/a/file" -d "/a/dir"
  assert_success
  local url
  url="$(opened_url)"
  [[ "$url" == *"q=prompt"* ]]
  [[ "$url" == *"file=%2Fa%2Ffile"* ]]
  [[ "$url" == *"folder=%2Fa%2Fdir"* ]]
}

@test "cowork: multiple -f flags" {
  run "$SCRIPT" cowork -f "/file1" -f "/file2"
  assert_success
  local url
  url="$(opened_url)"
  [[ "$url" == *"file=%2Ffile1"* ]]
  [[ "$url" == *"file=%2Ffile2"* ]]
}

@test "cowork: multiple -d flags" {
  run "$SCRIPT" cowork -d "/dir1" -d "/dir2"
  assert_success
  local url
  url="$(opened_url)"
  [[ "$url" == *"folder=%2Fdir1"* ]]
  [[ "$url" == *"folder=%2Fdir2"* ]]
}

@test "cowork: -q - reads from stdin" {
  run bash -c "printf 'cowork prompt' | '$SCRIPT' cowork -q -"
  assert_success
  assert_equal "$(opened_url)" "claude://cowork/new?q=cowork%20prompt"
}

# --------------------------------------------------------------------------- #
# resume command
# --------------------------------------------------------------------------- #

@test "resume: valid UUID" {
  run "$SCRIPT" resume "550e8400-e29b-41d4-a716-446655440000"
  assert_success
  assert_equal "$(opened_url)" "claude://resume?session=550e8400-e29b-41d4-a716-446655440000"
}

@test "resume: with --cwd" {
  run "$SCRIPT" resume "550e8400-e29b-41d4-a716-446655440000" --cwd "/home/user/project"
  assert_success
  local url
  url="$(opened_url)"
  [[ "$url" == *"session=550e8400-e29b-41d4-a716-446655440000"* ]]
  [[ "$url" == *"cwd=%2Fhome%2Fuser%2Fproject"* ]]
}

@test "resume: invalid UUID fails" {
  run "$SCRIPT" resume "not-a-uuid"
  assert_failure
  assert_output --partial "Invalid session UUID"
}

@test "resume: missing UUID fails" {
  run "$SCRIPT" resume
  assert_failure
}

# --------------------------------------------------------------------------- #
# settings command
# --------------------------------------------------------------------------- #

@test "settings: no page opens /settings" {
  run "$SCRIPT" settings
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/settings"
}

@test "settings: valid page 'general'" {
  run "$SCRIPT" settings general
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/settings/general"
}

@test "settings: valid page 'claude-code'" {
  run "$SCRIPT" settings claude-code
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/settings/claude-code"
}

@test "settings: valid page 'desktop/extensions'" {
  run "$SCRIPT" settings desktop/extensions
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/settings/desktop/extensions"
}

@test "settings: invalid page fails" {
  run "$SCRIPT" settings nonexistent
  assert_failure
  assert_output --partial "Invalid settings page"
}

# --------------------------------------------------------------------------- #
# customize command
# --------------------------------------------------------------------------- #

@test "customize: no subcommand opens /customize" {
  run "$SCRIPT" customize
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/customize"
}

@test "customize skills: opens /customize/skills" {
  run "$SCRIPT" customize skills
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/customize/skills"
}

@test "customize connectors: opens /customize/connectors" {
  run "$SCRIPT" customize connectors
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/customize/connectors"
}

@test "customize: unknown subcommand fails" {
  run "$SCRIPT" customize foobar
  assert_failure
  assert_output --partial "Unknown subcommand: foobar"
}

# --------------------------------------------------------------------------- #
# console command
# --------------------------------------------------------------------------- #

@test "console: opens https://platform.claude.com/" {
  run "$SCRIPT" console
  assert_success
  assert_equal "$(opened_url)" "https://platform.claude.com/"
}

# --------------------------------------------------------------------------- #
# logout command
# --------------------------------------------------------------------------- #

@test "logout: opens correct URL" {
  run "$SCRIPT" logout
  assert_success
  assert_equal "$(opened_url)" "claude://claude.ai/logout"
}

# --------------------------------------------------------------------------- #
# help flags
# --------------------------------------------------------------------------- #

@test "help: no args prints usage" {
  run "$SCRIPT"
  assert_success
  assert_output --partial "Usage: claude-desktop"
}

@test "help: --help prints usage" {
  run "$SCRIPT" --help
  assert_success
  assert_output --partial "Usage: claude-desktop"
}

@test "help: -h prints usage" {
  run "$SCRIPT" -h
  assert_success
  assert_output --partial "Usage: claude-desktop"
}

@test "help: new --help" {
  run "$SCRIPT" new --help
  assert_success
  assert_output --partial "Usage: claude-desktop new"
}

@test "help: chat --help" {
  run "$SCRIPT" chat --help
  assert_success
  assert_output --partial "Usage: claude-desktop chat"
}

@test "help: resume --help" {
  run "$SCRIPT" resume --help
  assert_success
  assert_output --partial "Usage: claude-desktop resume"
}

# --------------------------------------------------------------------------- #
# unknown command
# --------------------------------------------------------------------------- #

@test "unknown command prints error" {
  run "$SCRIPT" totally-unknown
  assert_failure
  assert_output --partial "Unknown command: totally-unknown"
}
