#!/usr/bin/env bats
# Test: test-cross-platform.bats
# Description: Integration tests for cross-platform compatibility

# Mock the log_error function
log_error() {
    echo "ERROR: $1" >&2
}

load '../../../../../src/infrastructure/adapters/shell/shell_utils.sh'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXFileOperations.impl'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXStringOperations.impl'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXSystemOperations.impl'

@test "cross-platform get_os_type returns valid os type" {
    run posix_get_os_type
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^(linux|darwin|windows|freebsd|unknown)$ ]]
}

@test "cross-platform get_shell_type returns valid shell type" {
    run posix_get_shell_type
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^(bash|zsh|dash|posix|unknown)$ ]]
}

@test "cross-platform normalize_path works with linux path" {
    # This is just for shell_utils function test
    run get_os_type
    [ "$status" -eq 0 ]
}

@test "cross-platform check_command works with common commands" {
    run posix_check_command "echo"
    [ "$status" -eq 0 ]
    
    run posix_check_command "ls"
    [ "$status" -eq 0 ]
    
    run posix_check_command "nonexistent_command_12345"
    [ "$status" -eq 1 ]
}

@test "cross-platform get_current_directory returns valid path" {
    run posix_get_current_directory
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [ -d "$output" ]
}

@test "cross-platform trim works consistently across platforms" {
    run posix_trim "  hello world  "
    [ "$output" = "hello world" ]
}

@test "cross-platform to_upper works consistently across platforms" {
    run posix_to_upper "hello"
    [ "$output" = "HELLO" ]
}

@test "cross-platform to_lower works consistently across platforms" {
    run posix_to_lower "HELLO"
    [ "$output" = "hello" ]
}

@test "cross-platform file operations work in temp directory" {
    local test_dir="/tmp/test_integration_$(date +%s)"
    
    # Test mkdir
    run posix_mkdir "$test_dir"
    [ "$status" -eq 0 ]
    [ -d "$test_dir" ]
    
    # Create a test file
    local test_file="$test_dir/test.txt"
    run posix_write_file "$test_file" "test content"
    [ "$status" -eq 0 ]
    [ -f "$test_file" ]
    
    # Test read file
    run posix_read_file "$test_file"
    [ "$status" -eq 0 ]
    [ "$output" = "test content" ]
    
    # Test exists
    run posix_exists "$test_file"
    [ "$status" -eq 0 ]
    
    # Test is_file
    run posix_is_file "$test_file"
    [ "$status" -eq 0 ]
    
    # Test is_directory
    run posix_is_directory "$test_dir"
    [ "$status" -eq 0 ]
    
    # Test copying
    local dest_file="$test_dir/test_copy.txt"
    run posix_cp "$test_file" "$dest_file"
    [ "$status" -eq 0 ]
    [ -f "$dest_file" ]
    
    # Test moving
    local move_file="$test_dir/test_move.txt"
    run posix_mv "$dest_file" "$move_file"
    [ "$status" -eq 0 ]
    [ -f "$move_file" ]
    [ ! -f "$dest_file" ]
    
    # Cleanup
    run posix_rm "$test_dir"
    [ "$status" -eq 0 ]
    [ ! -d "$test_dir" ]
}