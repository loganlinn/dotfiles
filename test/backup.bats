#!/usr/bin/env bats

setup() {
  BACKUP="${BATS_TEST_DIRNAME}/../bin/backup"
  TEST_DIR="${BATS_TEST_TMPDIR}/backup"
  mkdir -p "$TEST_DIR"
}

@test "shows usage with --help" {
  run "$BACKUP" --help

  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage: backup" ]]
}

@test "copies a file beside its source" {
  local source="$TEST_DIR/file.txt"
  local source_parent
  printf 'backup data\n' >"$source"
  source_parent="$(cd "${source%/*}" && pwd -P)"

  run env BACKUP_TIMESTAMP=20260814T153045 "$BACKUP" "$source"

  [ "$status" -eq 0 ]
  [ "$output" = "$source_parent/file.txt.backup-20260814T153045" ]
  [ "$(cat "$output")" = 'backup data' ]
  [ "$(cat "$source")" = 'backup data' ]
}

@test "adds a sequence when the timestamped name exists" {
  local source="$TEST_DIR/file.txt"
  local source_parent
  printf 'backup data\n' >"$source"
  source_parent="$(cd "${source%/*}" && pwd -P)"

  run env BACKUP_TIMESTAMP=20260814T153045 "$BACKUP" "$source"
  [ "$status" -eq 0 ]

  run env BACKUP_TIMESTAMP=20260814T153045 "$BACKUP" "$source"

  [ "$status" -eq 0 ]
  [ "$output" = "$source_parent/file.txt.backup-20260814T153045-2" ]
  [ "$(cat "$output")" = 'backup data' ]
}

@test "copies a directory recursively" {
  local source="$TEST_DIR/project"
  mkdir -p "$source/nested"
  printf 'nested data\n' >"$source/nested/file.txt"

  run env BACKUP_TIMESTAMP=20260814T153045 "$BACKUP" "$source"

  [ "$status" -eq 0 ]
  [ -d "$output/nested" ]
  [ "$(cat "$output/nested/file.txt")" = 'nested data' ]
  [ -d "$source" ]
}

@test "copies a symbolic link without following it" {
  local source="$TEST_DIR/link"
  printf 'target data\n' >"$TEST_DIR/target"
  ln -s target "$source"

  run env BACKUP_TIMESTAMP=20260814T153045 "$BACKUP" "$source"

  [ "$status" -eq 0 ]
  [ -L "$output" ]
  [ "$(readlink "$output")" = target ]
}

@test "moves instead of copying with --move" {
  local source="$TEST_DIR/file.txt"
  printf 'move data\n' >"$source"

  run env BACKUP_TIMESTAMP=20260814T153045 "$BACKUP" --move "$source"

  [ "$status" -eq 0 ]
  [ ! -e "$source" ]
  [ "$(cat "$output")" = 'move data' ]
}

@test "writes a detached backup below --root" {
  local source="$TEST_DIR/worktree/ignored/cache"
  local backup_root="$TEST_DIR/backups"
  local source_parent
  mkdir -p "$source"
  printf 'cache data\n' >"$source/value"
  source_parent="$(cd "${source%/*}" && pwd -P)"
  backup_root="$(cd "${backup_root%/*}" && pwd -P)/${backup_root##*/}"

  run env BACKUP_TIMESTAMP=20260814T153045 "$BACKUP" --root "$backup_root" "$source"

  [ "$status" -eq 0 ]
  [ "$output" = "$backup_root$source_parent/cache.backup-20260814T153045" ]
  [ "$(cat "$output/value")" = 'cache data' ]
  [ -d "$source" ]
}

@test "rejects a detached root inside a directory source" {
  local source="$TEST_DIR/project"
  mkdir -p "$source"

  run "$BACKUP" --root "$source/backups" "$source"

  [ "$status" -eq 2 ]
  [[ "$output" =~ 'inside source directory' ]]
}
