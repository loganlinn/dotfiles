#!/usr/bin/env bats

setup() {
	export S3_SYNC="${BATS_TEST_DIRNAME}/../bin/s3-sync"
	export S3_DATA_HOME="$(mktemp -d)"

	# Fake aws CLI that records its arguments
	export FAKE_AWS_LOG="$S3_DATA_HOME/.aws-calls"
	mkdir -p "$S3_DATA_HOME/bin"
	cat >"$S3_DATA_HOME/bin/aws" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$FAKE_AWS_LOG"
SCRIPT
	chmod +x "$S3_DATA_HOME/bin/aws"
	export PATH="$S3_DATA_HOME/bin:$PATH"
}

teardown() {
	if [[ -n "$S3_DATA_HOME" && -d "$S3_DATA_HOME" ]]; then
		rm -rf "$S3_DATA_HOME"
	fi
}

# — help / usage —

@test "shows usage with no arguments" {
	run "$S3_SYNC"
	[ "$status" -eq 0 ]
	[[ "$output" =~ "Usage:" ]]
}

@test "shows usage with --help" {
	run "$S3_SYNC" --help
	[ "$status" -eq 0 ]
	[[ "$output" =~ "Usage:" ]]
	[[ "$output" =~ "S3_DATA_HOME" ]]
}

@test "shows usage with -h" {
	run "$S3_SYNC" -h
	[ "$status" -eq 0 ]
	[[ "$output" =~ "Usage:" ]]
}

# — argument construction —

@test "syncs bucket to local directory" {
	run "$S3_SYNC" my-bucket
	[ "$status" -eq 0 ]
	[ -d "$S3_DATA_HOME/my-bucket" ]
	run cat "$FAKE_AWS_LOG"
	[[ "$output" == "s3 sync s3://my-bucket/ $S3_DATA_HOME/my-bucket/" ]]
}

@test "syncs bucket with key prefix" {
	run "$S3_SYNC" my-bucket/some/prefix
	[ "$status" -eq 0 ]
	[ -d "$S3_DATA_HOME/my-bucket/some/prefix" ]
	run cat "$FAKE_AWS_LOG"
	[[ "$output" == "s3 sync s3://my-bucket/some/prefix/ $S3_DATA_HOME/my-bucket/some/prefix/" ]]
}

@test "strips leading s3:// from argument" {
	run "$S3_SYNC" s3://my-bucket/path
	[ "$status" -eq 0 ]
	run cat "$FAKE_AWS_LOG"
	[[ "$output" == "s3 sync s3://my-bucket/path/ $S3_DATA_HOME/my-bucket/path/" ]]
}

@test "strips trailing slash from argument" {
	run "$S3_SYNC" my-bucket/path/
	[ "$status" -eq 0 ]
	run cat "$FAKE_AWS_LOG"
	[[ "$output" == "s3 sync s3://my-bucket/path/ $S3_DATA_HOME/my-bucket/path/" ]]
}

# — flag pass-through —

@test "passes extra flags to aws s3 sync" {
	run "$S3_SYNC" my-bucket --delete --dryrun
	[ "$status" -eq 0 ]
	run cat "$FAKE_AWS_LOG"
	[[ "$output" == "s3 sync s3://my-bucket/ $S3_DATA_HOME/my-bucket/ --delete --dryrun" ]]
}

@test "passes --exclude and --include flags" {
	run "$S3_SYNC" my-bucket --exclude "*.log" --include "*.txt"
	[ "$status" -eq 0 ]
	run cat "$FAKE_AWS_LOG"
	[[ "$output" == "s3 sync s3://my-bucket/ $S3_DATA_HOME/my-bucket/ --exclude *.log --include *.txt" ]]
}

# — S3_DATA_HOME —

@test "uses S3_DATA_HOME override" {
	local custom_dir="$(mktemp -d)"
	S3_DATA_HOME="$custom_dir" run "$S3_SYNC" my-bucket
	[ "$status" -eq 0 ]
	[ -d "$custom_dir/my-bucket" ]
	rm -rf "$custom_dir"
}

@test "creates local directory if it does not exist" {
	[ ! -d "$S3_DATA_HOME/new-bucket" ]
	run "$S3_SYNC" new-bucket
	[ "$status" -eq 0 ]
	[ -d "$S3_DATA_HOME/new-bucket" ]
}

# — direction safety —

@test "always syncs s3 source to local destination" {
	run "$S3_SYNC" my-bucket
	[ "$status" -eq 0 ]
	run cat "$FAKE_AWS_LOG"
	# First argument after 's3 sync' must be the S3 URI
	[[ "$output" =~ ^"s3 sync s3://" ]]
}
