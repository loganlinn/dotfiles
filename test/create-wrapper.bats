#!/usr/bin/env bats

# Test for create-wrapper script
# Requires: bats-core, nix, jq

setup() {
    # Create temporary directory for test files
    export TEST_TEMP_DIR="$(mktemp -d)"
    export CREATE_WRAPPER="${BATS_TEST_DIRNAME}/../bin/create-wrapper"
    
    # Create a simple test executable
    export TEST_EXECUTABLE="$TEST_TEMP_DIR/test-app"
    cat > "$TEST_EXECUTABLE" << 'EOF'
#!/bin/bash
echo "Test app running with args: $*"
echo "NODE_ENV: ${NODE_ENV:-unset}"
echo "API_KEY: ${API_KEY:-unset}"
echo "PATH: $PATH"
EOF
    chmod +x "$TEST_EXECUTABLE"
    
    # Create a simple script in PATH for impure tests
    export TEST_PATH_DIR="$TEST_TEMP_DIR/bin"
    mkdir -p "$TEST_PATH_DIR"
    export PATH="$TEST_PATH_DIR:$PATH"
    
    cat > "$TEST_PATH_DIR/test-cmd" << 'EOF'
#!/bin/bash
echo "Path command executed with: $*"
echo "ENV_VAR: ${ENV_VAR:-unset}"
EOF
    chmod +x "$TEST_PATH_DIR/test-cmd"
}

teardown() {
    # Clean up temporary files
    if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Helper function to skip tests if nix is not available
check_nix() {
    if ! command -v nix >/dev/null 2>&1; then
        skip "nix command not available"
    fi
}

# Helper function to skip tests if jq is not available
check_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq command not available"
    fi
}

@test "create-wrapper shows help message" {
    run "$CREATE_WRAPPER" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage: create-wrapper" ]]
    [[ "$output" =~ "Create a wrapper script using nixpkgs makeWrapper" ]]
    [[ "$output" =~ "--impure" ]]
    [[ "$output" =~ "--set-from-op" ]]
}

@test "create-wrapper shows help with -h flag" {
    run "$CREATE_WRAPPER" -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage: create-wrapper" ]]
}

@test "create-wrapper requires executable argument" {
    run "$CREATE_WRAPPER"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Both executable and output path are required" ]]
}

@test "create-wrapper requires output path argument" {
    run "$CREATE_WRAPPER" "/bin/echo"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Both executable and output path are required" ]]
}

@test "create-wrapper rejects too many arguments" {
    run "$CREATE_WRAPPER" "/bin/echo" "wrapper" "extra"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Too many positional arguments" ]]
}

@test "create-wrapper rejects non-existent executable in strict mode" {
    run "$CREATE_WRAPPER" "/nonexistent/executable" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Executable '/nonexistent/executable' does not exist" ]]
    [[ "$output" =~ "Use --impure flag to allow runtime PATH resolution" ]]
}

@test "create-wrapper rejects non-executable file in strict mode" {
    local non_executable="$TEST_TEMP_DIR/not-executable"
    echo "not executable" > "$non_executable"
    
    run "$CREATE_WRAPPER" "$non_executable" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: '$non_executable' is not executable" ]]
}

@test "create-wrapper rejects unknown options" {
    run "$CREATE_WRAPPER" --unknown-option "/bin/echo" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Unknown option --unknown-option" ]]
}

@test "create-wrapper validates --set requires name and value" {
    run "$CREATE_WRAPPER" --set NAME "/bin/echo" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: --set requires NAME and VALUE arguments" ]]
}

@test "create-wrapper validates --prefix requires name and value" {
    run "$CREATE_WRAPPER" --prefix NAME "/bin/echo" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: --prefix requires NAME and VALUE arguments" ]]
}

@test "create-wrapper validates --run requires argument" {
    run "$CREATE_WRAPPER" --run "/bin/echo" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: --run requires an argument" ]]
}

@test "create-wrapper validates --set-from-op requires name and reference" {
    run "$CREATE_WRAPPER" --set-from-op NAME "/bin/echo" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: --set-from-op requires NAME and 1PASSWORD_REFERENCE arguments" ]]
}

@test "create-wrapper validates 1Password reference format" {
    run "$CREATE_WRAPPER" --set-from-op API_KEY "invalid-reference" "/bin/echo" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: 1Password reference must start with 'op://'" ]]
}

@test "create-wrapper accepts valid 1Password reference format" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" --set-from-op API_KEY "op://Private/API/key" "$TEST_EXECUTABLE" "$wrapper"
    
    # Should not fail on validation
    if [ "$status" -ne 0 ]; then
        echo "Output: $output"
        echo "Status: $status"
    fi
    
    # Test may fail on nix build but should pass validation
    [[ ! "$output" =~ "Error: 1Password reference must start with 'op://'" ]]
}

@test "create-wrapper warns about missing command in impure mode" {
    run "$CREATE_WRAPPER" --impure "nonexistent-command" "$TEST_TEMP_DIR/wrapper"
    [ "$status" -ne 0 ] # May fail on nix build, but should pass validation
    [[ "$output" =~ "Warning: Command 'nonexistent-command' not found in current PATH" ]]
}

@test "create-wrapper accepts existing command in impure mode" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" --impure "test-cmd" "$wrapper"
    
    # Should not show warning for existing command
    [[ ! "$output" =~ "Warning: Command 'test-cmd' not found" ]]
}

@test "create-wrapper creates output directory if it doesn't exist" {
    check_nix
    check_jq
    
    local wrapper_dir="$TEST_TEMP_DIR/new/nested/dir"
    local wrapper="$wrapper_dir/wrapper"
    
    run "$CREATE_WRAPPER" "$TEST_EXECUTABLE" "$wrapper"
    
    # Directory should be created even if nix build fails
    [ -d "$wrapper_dir" ]
}

# Integration tests that require nix to work
@test "create-wrapper creates basic wrapper" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" "$TEST_EXECUTABLE" "$wrapper"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Wrapper created: $wrapper" ]]
    [ -f "$wrapper" ]
    [ -x "$wrapper" ]
}

@test "create-wrapper creates wrapper with environment variables" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" --set NODE_ENV production "$TEST_EXECUTABLE" "$wrapper"
    
    [ "$status" -eq 0 ]
    [ -f "$wrapper" ]
    [ -x "$wrapper" ]
    
    # Test that the wrapper sets the environment variable
    run "$wrapper"
    [[ "$output" =~ "NODE_ENV: production" ]]
}

@test "create-wrapper creates wrapper with multiple environment variables" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" \
        --set NODE_ENV production \
        --set-default API_KEY "default-key" \
        "$TEST_EXECUTABLE" "$wrapper"
    
    [ "$status" -eq 0 ]
    [ -f "$wrapper" ]
    
    # Test environment variables are set
    run "$wrapper"
    [[ "$output" =~ "NODE_ENV: production" ]]
}

@test "create-wrapper creates wrapper with command line flags" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" --add-flags "--verbose --debug" "$TEST_EXECUTABLE" "$wrapper"
    
    [ "$status" -eq 0 ]
    [ -f "$wrapper" ]
    
    # Test that flags are passed to the wrapped command
    run "$wrapper"
    [[ "$output" =~ "--verbose --debug" ]]
}

@test "create-wrapper creates wrapper with PATH prefix" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    local extra_path="/extra/bin"
    
    run "$CREATE_WRAPPER" --prefix PATH : "$extra_path" "$TEST_EXECUTABLE" "$wrapper"
    
    [ "$status" -eq 0 ]
    [ -f "$wrapper" ]
    
    # Test that PATH is modified
    run "$wrapper"
    [[ "$output" =~ "$extra_path" ]]
}

@test "create-wrapper creates impure wrapper" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" --impure "test-cmd" "$wrapper"
    
    [ "$status" -eq 0 ]
    [ -f "$wrapper" ]
    [ -x "$wrapper" ]
}

@test "create-wrapper handles 1Password references" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" \
        --set-from-op API_KEY "op://Private/API/key" \
        --set-default-from-op SECRET "op://Private/Secret/value" \
        "$TEST_EXECUTABLE" "$wrapper"
    
    [ "$status" -eq 0 ]
    [ -f "$wrapper" ]
    
    # Wrapper should contain op commands (we can't test actual execution without op)
    grep -q "op read" "$wrapper"
}

@test "create-wrapper combines multiple features" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    run "$CREATE_WRAPPER" \
        --impure \
        --set NODE_ENV production \
        --set-from-op API_KEY "op://Private/API/key" \
        --prefix PATH : "/extra/bin" \
        --add-flags "--verbose" \
        "test-cmd" "$wrapper"
    
    [ "$status" -eq 0 ]
    [ -f "$wrapper" ]
    [ -x "$wrapper" ]
}

@test "create-wrapper cleans up temporary files on success" {
    check_nix
    check_jq
    
    local wrapper="$TEST_TEMP_DIR/wrapper"
    local temp_count_before=$(find /tmp -name "tmp.*" -type d 2>/dev/null | wc -l)
    
    run "$CREATE_WRAPPER" "$TEST_EXECUTABLE" "$wrapper"
    
    [ "$status" -eq 0 ]
    
    # Check that no additional temp directories were left behind
    local temp_count_after=$(find /tmp -name "tmp.*" -type d 2>/dev/null | wc -l)
    [ "$temp_count_after" -eq "$temp_count_before" ]
}

@test "create-wrapper cleans up temporary files on error" {
    local temp_count_before=$(find /tmp -name "tmp.*" -type d 2>/dev/null | wc -l)
    
    # This should fail due to non-existent executable
    run "$CREATE_WRAPPER" "/nonexistent" "$TEST_TEMP_DIR/wrapper"
    
    [ "$status" -ne 0 ]
    
    # Check that no additional temp directories were left behind
    local temp_count_after=$(find /tmp -name "tmp.*" -type d 2>/dev/null | wc -l)
    [ "$temp_count_after" -eq "$temp_count_before" ]
}