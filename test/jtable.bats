#!/usr/bin/env bats
# shellcheck disable=SC2154 # Bats defines these variables.

setup() {
  JTABLE="${BATS_TEST_DIRNAME}/../bin/jtable"
  command -v gum >/dev/null || skip 'gum is not installed'
}

@test "renders nested objects as tables inside cells" {
  run "$JTABLE" <<<'{"user":{"name":"Ada","active":true},"count":0,"missing":null}'
  [ "$status" -eq 0 ]
  [[ $output == *'│ user'*'│ ╭'* ]]
  [[ $output == *'│ │ name'*'Ada'*'│ │'* ]]
  [[ $output == *'│ │ active'*'true'*'│ │'* ]]
  [[ $output == *'│ count'*'0'* ]]
  [[ $output == *'│ missing'*'null'* ]]
}

@test "renders arrays with indices and recursively nested objects" {
  run "$JTABLE" <<<'[{"name":"Ada"},false,[1,2]]'
  [ "$status" -eq 0 ]
  [[ $output == *Index*Value* ]]
  [[ $output == *'│ 0'*'│ ╭'* ]]
  [[ $output == *'│ │ name'*Ada* ]]
  [[ $output == *'│ 1'*false* ]]
  [[ $output == *'│ │ 0'*1*'│ │ 1'*2* ]]
}

@test "preserves multiline strings quotes commas and Unicode" {
  run "$JTABLE" <<'EOF'
{"text":"héllo, \"world\"\nnext line"}
EOF
  [ "$status" -eq 0 ]
  [[ $output == *'héllo, "world"'* ]]
  [[ $output == *'next line'* ]]
}

@test "depth limit keeps deeper containers as compact JSON" {
  run "$JTABLE" --max-depth 1 <<<'{"user":{"roles":["admin"]}}'
  [ "$status" -eq 0 ]
  [[ $output == *'{"roles":["admin"]}'* ]]
  [[ $output != *'│ ╭'* ]]
  run "$JTABLE" --max-depth 0 <<<'{"user":{"active":true}}'
  [ "$status" -eq 0 ]
  [ "$output" = '{"user":{"active":true}}' ]
}

@test "handles empty containers scalar roots and empty input" {
  run "$JTABLE" <<<'{}'
  [ "$status" -eq 0 ]
  [[ $output == *Key*Value* ]]
  run "$JTABLE" <<<'[]'
  [ "$status" -eq 0 ]
  [[ $output == *Index*Value* ]]
  run "$JTABLE" <<<'null'
  [ "$status" -eq 0 ]
  [[ $output == *Value*null* ]]
  run "$JTABLE" </dev/null
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "accepts pretty-printed JSON and multiple input values" {
  run "$JTABLE" <<'EOF'
{
  "first": 1
}
{"second":2}
EOF
  [ "$status" -eq 0 ]
  [[ $output == *first*1*second*2* ]]
}

@test "rejects invalid JSON arguments and depth limits" {
  run "$JTABLE" <<<'{"broken":'
  [ "$status" -ne 0 ]
  [[ $output == *jtable:* ]]
  run "$JTABLE" --max-depth -1 </dev/null
  [ "$status" -eq 2 ]
  run "$JTABLE" --unknown </dev/null
  [ "$status" -eq 2 ]
}

@test "reports Gum failures instead of emitting an empty nested cell" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat >"$BATS_TEST_TMPDIR/bin/gum" <<'EOF'
#!/usr/bin/env bash
echo 'render failed' >&2
exit 1
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/gum"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run "$JTABLE" <<<'{"nested":{"a":1}}'
  [ "$status" -ne 0 ]
  [[ $output == *'jtable: gum table failed: render failed'* ]]
}

@test "help succeeds without reading stdin" {
  run "$JTABLE" --help </dev/null
  [ "$status" -eq 0 ]
  [[ $output == *'usage: jtable'* ]]
}
