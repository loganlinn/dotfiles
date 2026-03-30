#!/usr/bin/env bats

load test_helper/bats-support/load
load test_helper/bats-assert/load
load test_helper/bats-mock/stub.bash

# ---------------------------------------------------------------------------
# fixtures
# ---------------------------------------------------------------------------

KAGI_SUCCESS_RESPONSE='{"meta":{"id":"abc-123","node":"us-east","ms":1234},"data":{"output":"This is a summary.","tokens":500}}'
KAGI_TAKEAWAY_RESPONSE='{"meta":{"id":"abc-456","node":"us-east","ms":2000},"data":{"output":"- Point one\n- Point two","tokens":300}}'
KAGI_ERROR_RESPONSE='{"error":[{"msg":"Unauthorized","code":401}]}'
KAGI_EMPTY_OUTPUT='{"meta":{"id":"abc-789","node":"us-east","ms":100},"data":{"output":"","tokens":0}}'

# ---------------------------------------------------------------------------
# setup / teardown
# ---------------------------------------------------------------------------

setup() {
  export TEST_TEMP_DIR
  TEST_TEMP_DIR="$(mktemp -d)"
  export LIB="${BATS_TEST_DIRNAME}/../bin/kagi-summarize.bash"
  export CLI="${BATS_TEST_DIRNAME}/../bin/kagi-summarize"

  export KAGI_API_TOKEN="test-token-000"

  # Clear any env defaults
  unset KAGI_SUMMARIZE_ENGINE KAGI_SUMMARIZE_TYPE KAGI_SUMMARIZE_LANG \
    KAGI_SUMMARIZE_CACHE KAGI_SUMMARIZE_RAW KAGI_SUMMARIZE_QUIET
}

teardown() {
  rm -rf "$TEST_TEMP_DIR"
}

# Source the library in a subshell, then call the given function.
_run_fn() {
  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"${KAGI_API_TOKEN:-}"'"
    source "'"$LIB"'" || exit 1
    '"$*"'
  '
}

# ---------------------------------------------------------------------------
# source guard
# ---------------------------------------------------------------------------

@test "refuses direct execution" {
  run bash "$LIB"
  assert_failure
  assert_output --partial "This is a library"
}

@test "sources successfully" {
  _run_fn "true"
  assert_success
}

# ---------------------------------------------------------------------------
# CLI --help
# ---------------------------------------------------------------------------

@test "CLI --help shows usage" {
  run "$CLI" --help
  assert_success
  assert_output --partial "Usage: kagi-summarize"
  assert_output --partial "KAGI_API_TOKEN"
  assert_output --partial "op run"
}

@test "CLI -h shows usage" {
  run "$CLI" -h
  assert_success
  assert_output --partial "Usage: kagi-summarize"
}

# ---------------------------------------------------------------------------
# logging fallback (no gum)
# ---------------------------------------------------------------------------

@test "fallback log outputs level and message to stderr" {
  run bash -c '
    gum() { return 127; }
    hash() { [[ "$1" == "gum" ]] && return 1; command hash "$@"; }
    export -f gum hash
    export KAGI_API_TOKEN="tok"
    source "'"$LIB"'"
    _kagi_log --level error "something broke" 2>&1
  '
  assert_success
  assert_output --partial "ERROR: something broke"
}

@test "fallback fmt passes through stdin" {
  run bash -c '
    gum() { return 127; }
    hash() { [[ "$1" == "gum" ]] && return 1; command hash "$@"; }
    export -f gum hash
    export KAGI_API_TOKEN="tok"
    source "'"$LIB"'"
    echo "hello world" | _kagi_fmt
  '
  assert_success
  assert_output "hello world"
}

# ---------------------------------------------------------------------------
# dependency checks
# ---------------------------------------------------------------------------

@test "fails when curl is missing" {
  run bash -c '
    hash() { [[ "$1" == "curl" ]] && return 1; command hash "$@"; }
    export -f hash
    source "'"$LIB"'" 2>&1
  '
  assert_failure
  assert_output --partial "missing dependencies"
  assert_output --partial "curl"
}

@test "fails when jq is missing" {
  run bash -c '
    hash() { [[ "$1" == "jq" ]] && return 1; command hash "$@"; }
    export -f hash
    source "'"$LIB"'" 2>&1
  '
  assert_failure
  assert_output --partial "jq"
}

@test "fails when trurl is missing" {
  run bash -c '
    hash() { [[ "$1" == "trurl" ]] && return 1; command hash "$@"; }
    export -f hash
    source "'"$LIB"'" 2>&1
  '
  assert_failure
  assert_output --partial "trurl"
}

# ---------------------------------------------------------------------------
# _kagi_token / --api-token
# ---------------------------------------------------------------------------

@test "token returns KAGI_API_TOKEN" {
  _run_fn 'printf "%s" "$(_kagi_token)"'
  assert_success
  assert_output "test-token-000"
}

@test "token fails when unset" {
  export KAGI_API_TOKEN=""
  _run_fn '_kagi_token 2>&1'
  assert_failure
  assert_output --partial "KAGI_API_TOKEN is not set"
  assert_output --partial "--api-token"
  assert_output --partial "kagi.com/settings"
}

@test "--api-token overrides KAGI_API_TOKEN" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --api-token "override-tok" --text "test" --quiet --raw'
  assert_success

  unstub curl
}

@test "--api-token works without KAGI_API_TOKEN" {
  export KAGI_API_TOKEN=""
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --api-token "direct-tok" --text "test" --quiet --raw'
  assert_success

  unstub curl
}

@test "--api-token requires a value" {
  _run_fn 'kagi_summarize --api-token 2>&1'
  assert_failure
  assert_output --partial "--api-token requires a value"
}

# ---------------------------------------------------------------------------
# _kagi_in_list
# ---------------------------------------------------------------------------

@test "in_list matches present item" {
  _run_fn '_kagi_in_list cecil "cecil agnes daphne muriel"'
  assert_success
}

@test "in_list rejects absent item" {
  _run_fn '_kagi_in_list bob "cecil agnes daphne muriel"'
  assert_failure
}

@test "in_list no partial match" {
  _run_fn '_kagi_in_list ce "cecil agnes daphne muriel"'
  assert_failure
}

# ---------------------------------------------------------------------------
# _kagi_check_response
# ---------------------------------------------------------------------------

@test "check_response accepts valid response" {
  _run_fn '_kagi_check_response '"'$KAGI_SUCCESS_RESPONSE'"''
  assert_success
}

@test "check_response rejects non-JSON" {
  _run_fn '_kagi_check_response "curl: connection refused" 2>&1'
  assert_failure
  assert_output --partial "request failed"
}

@test "check_response detects API error" {
  _run_fn '_kagi_check_response '"'$KAGI_ERROR_RESPONSE'"' 2>&1'
  assert_failure
  assert_output --partial "Unauthorized"
}

# ---------------------------------------------------------------------------
# input validation
# ---------------------------------------------------------------------------

@test "fails with no input source" {
  _run_fn 'kagi_summarize 2>&1'
  assert_failure
  assert_output --partial "one of --url, --file, or --text is required"
}

@test "fails with both --url and --text" {
  _run_fn 'kagi_summarize --url "https://example.com" --text "hello" 2>&1'
  assert_failure
  assert_output --partial "mutually exclusive"
}

@test "fails with both --url and --file" {
  _run_fn 'kagi_summarize --url "https://example.com" --file /tmp/x 2>&1'
  assert_failure
  assert_output --partial "mutually exclusive"
}

@test "fails with --url --file --text" {
  _run_fn 'kagi_summarize --url "https://x.com" --file /tmp/x --text "hi" 2>&1'
  assert_failure
  assert_output --partial "mutually exclusive"
}

@test "fails with unknown option" {
  _run_fn 'kagi_summarize --bogus 2>&1'
  assert_failure
  assert_output --partial "unknown option: --bogus"
}

@test "fails when --url has no value" {
  _run_fn 'kagi_summarize --url 2>&1'
  assert_failure
  assert_output --partial "--url requires a value"
}

@test "fails when --file has no value" {
  _run_fn 'kagi_summarize --file 2>&1'
  assert_failure
  assert_output --partial "--file requires a value"
}

@test "fails when --text has no value" {
  _run_fn 'kagi_summarize --text 2>&1'
  assert_failure
  assert_output --partial "--text requires a value"
}

@test "fails when --engine has no value" {
  _run_fn 'kagi_summarize --url "https://example.com" --engine 2>&1'
  assert_failure
  assert_output --partial "--engine requires a value"
}

@test "fails when --type has no value" {
  _run_fn 'kagi_summarize --url "https://example.com" --type 2>&1'
  assert_failure
  assert_output --partial "--type requires a value"
}

@test "fails when --lang has no value" {
  _run_fn 'kagi_summarize --url "https://example.com" --lang 2>&1'
  assert_failure
  assert_output --partial "--lang requires a value"
}

# ---------------------------------------------------------------------------
# engine / type / language validation
# ---------------------------------------------------------------------------

@test "rejects invalid engine" {
  _run_fn 'kagi_summarize --url "https://example.com" --engine bogus 2>&1'
  assert_failure
  assert_output --partial "invalid engine: bogus"
}

@test "accepts valid engines" {
  for e in cecil agnes daphne muriel; do
    run bash -c '
      export KAGI_API_TOKEN="tok"
      source "'"$LIB"'"
      kagi_summarize --url "https://example.com" --engine '"$e"' --quiet 2>&1
    '
    refute_output --partial "invalid engine"
  done
}

@test "rejects invalid summary type" {
  _run_fn 'kagi_summarize --url "https://example.com" --type essay 2>&1'
  assert_failure
  assert_output --partial "invalid type: essay"
}

@test "rejects invalid language" {
  _run_fn 'kagi_summarize --url "https://example.com" --lang XX 2>&1'
  assert_failure
  assert_output --partial "invalid language: XX"
}

@test "accepts valid language codes" {
  for lang in EN DE JA ZH-HANT; do
    run bash -c '
      export KAGI_API_TOKEN="tok"
      source "'"$LIB"'"
      kagi_summarize --url "https://example.com" --lang '"$lang"' --quiet 2>&1
    '
    refute_output --partial "invalid language"
  done
}

# ---------------------------------------------------------------------------
# file input
# ---------------------------------------------------------------------------

@test "reads text from file" {
  local f="$TEST_TEMP_DIR/input.txt"
  echo "some text content" >"$f"

  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --file "'"$f"'" --quiet --raw'
  assert_success
  assert_output --partial '"output": "This is a summary."'

  unstub curl
}

@test "reads text from stdin via --file -" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"$KAGI_API_TOKEN"'"
    source "'"$LIB"'"
    echo "piped content" | kagi_summarize --file - --quiet --raw
  '
  assert_success
  assert_output --partial '"output": "This is a summary."'

  unstub curl
}

@test "fails on nonexistent file" {
  _run_fn 'kagi_summarize --file "/no/such/file" 2>&1'
  assert_failure
  assert_output --partial "file not found"
}

@test "fails on empty file" {
  local f="$TEST_TEMP_DIR/empty.txt"
  : >"$f"

  _run_fn 'kagi_summarize --file "'"$f"'" 2>&1'
  assert_failure
  assert_output --partial "empty input"
}

# ---------------------------------------------------------------------------
# URL validation
# ---------------------------------------------------------------------------

@test "rejects ftp scheme" {
  _run_fn 'kagi_summarize --url "ftp://example.com/file" 2>&1'
  assert_failure
  assert_output --partial "unsupported scheme: ftp"
}

@test "accepts https URL" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --url "https://example.com/article" --quiet --raw'
  assert_success

  unstub curl
}

@test "accepts http URL" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --url "http://example.com/article" --quiet --raw'
  assert_success

  unstub curl
}

# ---------------------------------------------------------------------------
# URL request (GET path)
# ---------------------------------------------------------------------------

@test "GET request builds correct URL with trurl" {
  stub curl '-sfS * : echo '"'$KAGI_SUCCESS_RESPONSE'"''

  _run_fn 'kagi_summarize --url "https://example.com/article" --quiet --raw'
  assert_success

  unstub curl
}

@test "GET request includes engine param" {
  stub curl '-sfS * : echo '"'$KAGI_SUCCESS_RESPONSE'"''

  _run_fn 'kagi_summarize --url "https://example.com" --engine agnes --quiet --raw'
  assert_success

  unstub curl
}

@test "GET request includes cache=false with --no-cache" {
  stub curl '-sfS * : echo '"'$KAGI_SUCCESS_RESPONSE'"''

  _run_fn 'kagi_summarize --url "https://example.com" --no-cache --quiet --raw'
  assert_success

  unstub curl
}

# ---------------------------------------------------------------------------
# text request (POST path)
# ---------------------------------------------------------------------------

@test "POST sends JSON body with text" {
  stub curl '-sfS * : echo '"'$KAGI_SUCCESS_RESPONSE'"''

  _run_fn 'kagi_summarize --text "hello world" --quiet --raw'
  assert_success
  assert_output --partial '"output": "This is a summary."'

  unstub curl
}

# ---------------------------------------------------------------------------
# response handling
# ---------------------------------------------------------------------------

@test "raw mode outputs valid JSON" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --text "test" --quiet --raw'
  assert_success
  run bash -c 'echo '"'"''"$output"''"'"' | jq -r ".data.output"'
  assert_output "This is a summary."

  unstub curl
}

@test "formatted mode outputs summary text" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --text "test" --quiet'
  assert_success
  assert_output --partial "This is a summary."

  unstub curl
}

@test "reports API errors" {
  stub curl "-sfS * : echo '$KAGI_ERROR_RESPONSE'"

  _run_fn 'kagi_summarize --text "test" --quiet 2>&1'
  assert_failure
  assert_output --partial "Unauthorized"

  unstub curl
}

@test "fails on empty API output" {
  stub curl "-sfS * : echo '$KAGI_EMPTY_OUTPUT'"

  _run_fn 'kagi_summarize --text "test" --quiet 2>&1'
  assert_failure
  assert_output --partial "empty response from API"

  unstub curl
}

@test "handles curl failure" {
  stub curl "-sfS * : echo 'curl: (7) connection refused'; exit 22"

  _run_fn 'kagi_summarize --text "test" --quiet 2>&1'
  assert_failure

  unstub curl
}

# ---------------------------------------------------------------------------
# env var defaults (env → flags chain)
# ---------------------------------------------------------------------------

@test "KAGI_SUMMARIZE_ENGINE env var is used as default" {
  stub curl '-sfS * : echo '"'$KAGI_SUCCESS_RESPONSE'"''

  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"$KAGI_API_TOKEN"'"
    export KAGI_SUMMARIZE_ENGINE=daphne
    source "'"$LIB"'"
    kagi_summarize --url "https://example.com" --quiet --raw
  '
  assert_success

  unstub curl
}

@test "flag overrides KAGI_SUMMARIZE_ENGINE env var" {
  stub curl '-sfS * : echo '"'$KAGI_SUCCESS_RESPONSE'"''

  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"$KAGI_API_TOKEN"'"
    export KAGI_SUMMARIZE_ENGINE=daphne
    source "'"$LIB"'"
    kagi_summarize --url "https://example.com" --engine muriel --quiet --raw
  '
  assert_success

  unstub curl
}

@test "KAGI_SUMMARIZE_CACHE=false env var disables cache" {
  stub curl '-sfS * : echo '"'$KAGI_SUCCESS_RESPONSE'"''

  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"$KAGI_API_TOKEN"'"
    export KAGI_SUMMARIZE_CACHE=false
    source "'"$LIB"'"
    kagi_summarize --url "https://example.com" --quiet --raw
  '
  assert_success

  unstub curl
}

@test "KAGI_SUMMARIZE_LANG env var sets language" {
  stub curl '-sfS * : echo '"'$KAGI_SUCCESS_RESPONSE'"''

  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"$KAGI_API_TOKEN"'"
    export KAGI_SUMMARIZE_LANG=JA
    source "'"$LIB"'"
    kagi_summarize --url "https://example.com" --quiet --raw
  '
  assert_success

  unstub curl
}

@test "KAGI_SUMMARIZE_RAW=true outputs JSON" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"$KAGI_API_TOKEN"'"
    export KAGI_SUMMARIZE_RAW=true
    source "'"$LIB"'"
    kagi_summarize --text "test" --quiet
  '
  assert_success
  assert_output --partial '"output": "This is a summary."'

  unstub curl
}

@test "KAGI_SUMMARIZE_QUIET=true suppresses progress" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"$KAGI_API_TOKEN"'"
    export KAGI_SUMMARIZE_QUIET=true
    source "'"$LIB"'"
    kagi_summarize --text "test" 2>&1
  '
  assert_success
  refute_output --partial "summarizing"

  unstub curl
}

@test "--raw flag overrides KAGI_SUMMARIZE_RAW=false" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  run bash -c '
    export PATH="'"$BATS_MOCK_BINDIR"':$PATH"
    export KAGI_API_TOKEN="'"$KAGI_API_TOKEN"'"
    export KAGI_SUMMARIZE_RAW=false
    source "'"$LIB"'"
    kagi_summarize --text "test" --raw --quiet
  '
  assert_success
  assert_output --partial '"output": "This is a summary."'

  unstub curl
}

# ---------------------------------------------------------------------------
# quiet / verbose
# ---------------------------------------------------------------------------

@test "quiet suppresses progress log" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --text "test" --quiet 2>&1'
  assert_success
  refute_output --partial "summarizing"

  unstub curl
}

@test "non-quiet shows progress" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  _run_fn 'kagi_summarize --text "test" 2>&1'
  assert_success
  assert_output --partial "summarizing"

  unstub curl
}

# ---------------------------------------------------------------------------
# CLI wrapper
# ---------------------------------------------------------------------------

@test "CLI passes bare URL as --url" {
  stub curl "-sfS * : echo '$KAGI_SUCCESS_RESPONSE'"

  PATH="$BATS_MOCK_BINDIR:$PATH" \
    KAGI_API_TOKEN="$KAGI_API_TOKEN" \
    run "$CLI" https://example.com --quiet --raw
  assert_success
  assert_output --partial '"output": "This is a summary."'

  unstub curl
}
