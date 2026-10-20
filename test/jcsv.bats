#!/usr/bin/env bats
# shellcheck disable=SC2154 # Bats defines these variables.

setup() {
  JCSV="${BATS_TEST_DIRNAME}/../bin/jcsv"
}

@test "defaults object entries to key and value rows in input order" {
  run "$JCSV" <<'EOF'
{"z":"hello, \"world\"","active":false,"count":0,"missing":null,"nested":{"a":1},"items":[1,2]}
EOF
  [ "$status" -eq 0 ]
  [ "$output" = $'"Key","Value"\n"z","hello, ""world"""\n"active",false\n"count",0\n"missing",\n"nested","{""a"":1}"\n"items","[1,2]"' ]
}

@test "default mode handles JSON Lines and empty objects with one header" {
  run "$JCSV" <<'EOF'
{}
{"first":1}
{"second":2}
EOF
  [ "$status" -eq 0 ]
  [ "$output" = $'"Key","Value"\n"first",1\n"second",2' ]
  run "$JCSV" <<<'{}'
  [ "$status" -eq 0 ]
  [ "$output" = '"Key","Value"' ]
  run "$JCSV" </dev/null
  [ "$status" -eq 0 ]
  [ "$output" = '"Key","Value"' ]
}

@test "default mode rejects non-object inputs with guidance" {
  local input
  for input in '[]' '1' '"text"' 'true' 'null'; do
    run "$JCSV" <<<"$input"
    [ "$status" -ne 0 ]
    [[ $output == *'default mode requires an object; use explicit row and column expressions'* ]]
  done
}

@test "selects rows from nested JSON with labeled columns" {
  run "$JCSV" '.items[] | select(.active)' -c Name '.name' --col Count '.tags | length' <<'EOF'
{"items":[{"name":"Ada","active":true,"tags":["a","b"]},{"name":"Bo","active":false}]}
EOF
  [ "$status" -eq 0 ]
  [ "$output" = $'"Name","Count"\n"Ada",2' ]
}

@test "defaults rows to identity and emits one header for JSON Lines" {
  run "$JCSV" -c '.name' '.name' --col Active '.active' <<'EOF'
{"name":"Ada","active":false}
{"name":"Bo","active":true}
EOF
  [ "$status" -eq 0 ]
  [ "$output" = $'".name","Active"\n"Ada",false\n"Bo",true' ]
}

@test "positional columns work with array rows" {
  run "$JCSV" '.[]' '.[0]' '.[1]' <<'EOF'
[["Ada",9],["Bo",0]]
EOF
  [ "$status" -eq 0 ]
  [ "$output" = $'".[0]",".[1]"\n"Ada",9\n"Bo",0' ]
}

@test "columns can handle mixed scalar object and array rows" {
  run "$JCSV" '.[]' -c Value '.' -c Type 'type' <<'EOF'
[null,false,0,"hello",[1,2],{"a":1}]
EOF
  [ "$status" -eq 0 ]
  [ "$output" = $'"Value","Type"\n,"null"\nfalse,"boolean"\n0,"number"\n"hello","string"\n"[1,2]","array"\n"{""a"":1}","object"' ]
}

@test "missing fields stay aligned and false does not become null" {
  run "$JCSV" '.[]' '.a' '.b' '.c' <<'EOF'
[{"a":false,"c":0},{}]
EOF
  [ "$status" -eq 0 ]
  [ "$output" = $'".a",".b",".c"\nfalse,,0\n,,' ]
}

@test "quotes commas double quotes and embedded newlines as CSV" {
  run "$JCSV" -c Text '.text' <<'EOF'
{"text":"hello, \"world\"\nnext line"}
EOF
  [ "$status" -eq 0 ]
  [ "$output" = $'"Text"\n"hello, ""world""\nnext line"' ]
}

@test "empty input and empty row sequences emit only the header" {
  run "$JCSV" -c Value '.' </dev/null
  [ "$status" -eq 0 ]
  [ "$output" = '"Value"' ]
  run "$JCSV" '.[]' -c Value '.' <<<'[]'
  [ "$status" -eq 0 ]
  [ "$output" = '"Value"' ]
}

@test "rejects columns that emit no value or multiple values" {
  run "$JCSV" -c Empty 'empty' <<<'{}'
  [ "$status" -ne 0 ]
  [[ $output == *'column 1 must emit exactly one value'* ]]
  run "$JCSV" -c Value '.' -c Items '.[]' <<<'[1,2]'
  [ "$status" -ne 0 ]
  [[ $output == *'column 2 must emit exactly one value'* ]]
}

@test "an explicit array collects multiple column results into one cell" {
  run "$JCSV" -c Values '[.[]]' <<<'[1,2]'
  [ "$status" -eq 0 ]
  [ "$output" = $'"Values"\n"[1,2]"' ]
}

@test "positional columns preserve jq comparisons assignments and string literals" {
  run "$JCSV" '.' 'length==2' '.a = 3' '"x=y"' <<<'{"a":1,"b":2}'
  [ "$status" -eq 0 ]
  [ "$output" = $'"length==2",".a = 3","""x=y"""\ntrue,"{""a"":3,""b"":2}","x=y"' ]
}

@test "headers are literal data and trailing jq comments are supported" {
  run "$JCSV" '.[] # rows' -c '. # "quoted header"' '. # column' -c Count-2 'length # column' <<<'[[1,2]]'
  [ "$status" -eq 0 ]
  [ "$output" = $'". # ""quoted header""","Count-2"\n"[1,2]",2' ]
}

@test "two-argument columns accept arbitrary labels and plain jq assignments" {
  run "$JCSV" -c 'a=b, "label"' '.a = 3' --col '' '.a' -c --help '-.a' <<<'{"a":1}'
  [ "$status" -eq 0 ]
  [ "$output" = $'"a=b, ""label""","","--help"\n"{""a"":3}",1,-1' ]
}

@test "end of options allows filters beginning with a hyphen" {
  run "$JCSV" -c Value '.' -- '-.' <<<'2'
  [ "$status" -eq 0 ]
  [ "$output" = $'"Value"\n-2' ]
}

@test "invalid JSON and invalid filters return failures" {
  run "$JCSV" -c Value '.' <<<'{"broken":'
  [ "$status" -ne 0 ]
  run "$JCSV" -c Value '.[' <<<'{}'
  [ "$status" -ne 0 ]
  run "$JCSV" '.[' '.' <<<'{}'
  [ "$status" -ne 0 ]
  run "$JCSV" '.[]' '.' <<<'1'
  [ "$status" -ne 0 ]
}

@test "rejects ambiguous or missing arguments" {
  run "$JCSV" '.[]' </dev/null
  [ "$status" -eq 2 ]
  run "$JCSV" -c
  [ "$status" -eq 2 ]
  run "$JCSV" -c Value '.' '.[]' '.name'
  [ "$status" -eq 2 ]
  run "$JCSV" -c Name
  [ "$status" -eq 2 ]
  [[ $output == *'requires a label and a column expression'* ]]
  run "$JCSV" --col Name
  [ "$status" -eq 2 ]
  [[ $output == *'requires a label and a column expression'* ]]
  run "$JCSV" -c Name ''
  [ "$status" -eq 2 ]
  run "$JCSV" '' '.'
  [ "$status" -eq 2 ]
  run "$JCSV" --invalid
  [ "$status" -eq 2 ]
}

@test "help succeeds without reading stdin" {
  run "$JCSV" --help </dev/null
  [ "$status" -eq 0 ]
  [[ $output == $'Usage: jcsv\n'* ]]
}

@test "CSV works with gum table" {
  command -v gum >/dev/null || skip 'gum is not installed'
  "$JCSV" '.[]' -c Name '.name' -c Score '.score' >"$BATS_TEST_TMPDIR/table.csv" <<'EOF'
[{"name":"Ada, A.","score":9},{"name":"Bo","score":0}]
EOF
  run gum table --print --file "$BATS_TEST_TMPDIR/table.csv"
  [ "$status" -eq 0 ]
  [[ $output == *Name*Score* ]]
  [[ $output == *'Ada, A.'*9* ]]
  [[ $output == *Bo*0* ]]
}
