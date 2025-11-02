#!/usr/bin/env bats
# Test: test-cross-platform-workflows.bats
# Description: Comprehensive cross-platform workflow tests

# Mock the log_error function
log_error() {
    echo "ERROR: $1" >&2
}

load '../../../../../src/infrastructure/adapters/shell/shell_utils.sh'
load '../../../../../src/infrastructure/adapters/shell/cross_platform_utils.sh'
load '../../../../../src/infrastructure/adapters/shell/ShellFactory.impl'
load '../../../../../src/infrastructure/adapters/shell/ShellAbstraction.impl'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXFileOperations.impl'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXStringOperations.impl'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXProcessOperations.impl'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXSystemOperations.impl'

@test "cross-platform workflow: complete file operation sequence" {
    local test_dir="/tmp/test_workflow_$(date +%s)"
    local test_file="$test_dir/test.txt"
    local backup_file="$test_dir/test_backup.txt"
    
    # Create directory
    run shell_abstraction_mkdir "$test_dir"
    [ "$status" -eq 0 ]
    [ -d "$test_dir" ]
    
    # Write file
    run posix_write_file "$test_file" "workflow test content"
    [ "$status" -eq 0 ]
    [ -f "$test_file" ]
    
    # Read file
    run posix_read_file "$test_file"
    [ "$status" -eq 0 ]
    [ "$output" = "workflow test content" ]
    
    # Copy file
    run posix_cp "$test_file" "$backup_file"
    [ "$status" -eq 0 ]
    [ -f "$backup_file" ]
    
    # Verify copied content
    run posix_read_file "$backup_file"
    [ "$status" -eq 0 ]
    [ "$output" = "workflow test content" ]
    
    # Move file (rename in this case)
    local moved_file="$test_dir/moved_test.txt"
    run posix_mv "$backup_file" "$moved_file"
    [ "$status" -eq 0 ]
    [ -f "$moved_file" ]
    [ ! -f "$backup_file" ]
    
    # Verify moved content
    run posix_read_file "$moved_file"
    [ "$status" -eq 0 ]
    [ "$output" = "workflow test content" ]
    
    # Remove directory and contents
    run shell_abstraction_rm "$test_dir"
    [ "$status" -eq 0 ]
    [ ! -d "$test_dir" ]
}

@test "cross-platform workflow: string processing pipeline" {
    local input="  Hello, World! This is a TEST string.  "
    local result
    
    # Trim whitespace
    run shell_abstraction_trim "$input"
    [ "$status" -eq 0 ]
    result="$output"
    
    # Convert to lower case
    run posix_to_lower "$result"
    [ "$status" -eq 0 ]
    result="$output"
    
    # Replace word
    run posix_replace "$result" "test" "cross-platform"
    [ "$status" -eq 0 ]
    result="$output"
    
    # Verify final result
    [ "$result" = "hello, world! this is a cross-platform string." ]
}

@test "cross-platform workflow: process monitoring" {
    # Start a background sleep process
    sleep 10 &
    bg_pid=$!
    
    # Check if process is running
    run posix_is_process_running "$bg_pid"
    [ "$status" -eq 0 ]
    
    # Get current PID
    run shell_abstraction_get_pid
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [ "$output" -gt 0 ]
    
    # Kill the background process
    run shell_abstraction_kill_process "$bg_pid"
    # This may fail if process already ended, so we don't check status
}

@test "cross-platform workflow: system information gathering" {
    # Test OS detection
    run shell_abstraction_get_os_type
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [[ "$output" =~ ^(linux|darwin|windows|freebsd|unknown)$ ]]
    
    # Test shell detection
    run shell_abstraction_get_shell_type
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [[ "$output" =~ ^(bash|zsh|dash|posix|unknown)$ ]]
    
    # Test command availability
    run shell_abstraction_check_command "sh"
    [ "$status" -eq 0 ]
    
    # Test current directory
    run posix_get_current_directory
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [ -d "$output" ]
}

@test "cross-platform workflow: path normalization" {
    local test_path="/tmp/test/path"
    
    # Test platform detection
    run get_platform_type
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Test path separator
    run get_path_separator
    [ "$status" -eq 0 ]
    [ -n "$output" ]  # Either / or \ depending on platform
    
    # Test path normalization
    if is_unix_platform; then
        # On Unix-like, normalize_path should convert backslashes to forward slashes
        run normalize_path "C:\\temp\\test"
        [ "$status" -eq 0 ]
        # This would convert backslashes to forward slashes
    else
        # On Windows, it would convert forward slashes to backslashes
        run normalize_path "/temp/test"
        [ "$status" -eq 0 ]
    fi
}

@test "cross-platform workflow: adapter selection" {
    # Test factory methods
    run shell_factory_create_adapter
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    run shell_factory_create_file_operations
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    run shell_factory_create_string_operations
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    run shell_factory_create_process_operations
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    run shell_factory_create_system_operations
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "cross-platform workflow: error handling consistency" {
    # Test error handling for non-existent paths
    run posix_exists "/non/existent/path"
    [ "$status" -eq 1 ]
    
    run posix_is_directory "/non/existent/path"
    [ "$status" -eq 1 ]
    
    run posix_is_file "/non/existent/file.txt"
    [ "$status" -eq 1 ]
    
    run posix_read_file "/non/existent/file.txt"
    [ "$status" -eq 1 ]
    
    # Test error handling for invalid operations
    run posix_mkdir ""
    [ "$status" -eq 1 ]
    
    run posix_rm ""
    [ "$status" -eq 1 ]
    
    run posix_cp "" ""
    [ "$status" -eq 1 ]
    
    run posix_mv "" ""
    [ "$status" -eq 1 ]
}

@test "cross-platform workflow: command execution" {
    # Test successful command execution
    run shell_abstraction_execute echo "test output"
    [ "$status" -eq 0 ]
    [ "$output" = "test output" ]
    
    # Test failing command execution
    run shell_abstraction_execute sh -c "exit 1"
    [ "$status" -ne 0 ]
}