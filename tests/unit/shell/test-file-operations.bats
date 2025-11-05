#!/usr/bin/env bats

setup() {
    . "${BATS_TEST_DIRNAME}/../../../src/infrastructure/shell/operations/FileOperations.interface"
    
    # POSIX: mktemp for temp directory
    TEST_DIR="${BATS_TEST_TMPDIR}/devmorph_test_$$"
    mkdir -p "$TEST_DIR"
}

teardown() {
    # POSIX: rm -rf for cleanup
    rm -rf "$TEST_DIR"
}

@test "Should check if path exists (POSIX)" {
    # Create test file
    touch "$TEST_DIR/test_file"
    
    # POSIX test
    path_exists "$TEST_DIR/test_file"
    [ $? -eq 0 ]
    
    # POSIX negation
    if path_exists "$TEST_DIR/nonexistent"; then
        return 1
    fi
}

@test "Should create directory safely (POSIX)" {
    safe_mkdir "$TEST_DIR/deep/nested/dir"
    
    # POSIX test for directory
    [ -d "$TEST_DIR/deep/nested/dir" ]
}

@test "Should copy file (POSIX)" {
    # POSIX: printf instead of echo for portability
    printf "%s\n" "content" > "$TEST_DIR/source"
    
    safe_cp "$TEST_DIR/source" "$TEST_DIR/dest"
    
    [ -f "$TEST_DIR/dest" ]
    
    # POSIX: Use [ ] for comparison
    content=$(cat "$TEST_DIR/dest")
    [ "$content" = "content" ]
}
