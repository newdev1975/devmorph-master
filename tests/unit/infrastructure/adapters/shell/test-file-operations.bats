#!/usr/bin/env bats
# Test: test-file-operations.bats
# Description: Unit tests for core file operations

# Mock the log_error function
log_error() {
    echo "ERROR: $1" >&2
}

load '../../../../../src/infrastructure/adapters/shell/shell_utils.sh'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXFileOperations.impl'

@test "posix_mkdir creates directory successfully" {
    local test_dir="/tmp/test_posix_mkdir_$(date +%s)"
    run posix_mkdir "$test_dir"
    [ "$status" -eq 0 ]
    [ -d "$test_dir" ]
    rm -rf "$test_dir"
}

@test "posix_mkdir handles empty path" {
    run posix_mkdir ""
    [ "$status" -eq 1 ]
}

@test "posix_rm removes file successfully" {
    local test_file="/tmp/test_posix_rm_$(date +%s).txt"
    touch "$test_file"
    [ -f "$test_file" ]
    run posix_rm "$test_file"
    [ "$status" -eq 0 ]
    [ ! -f "$test_file" ]
}

@test "posix_rm removes directory successfully" {
    local test_dir="/tmp/test_posix_rm_dir_$(date +%s)"
    mkdir -p "$test_dir"
    [ -d "$test_dir" ]
    run posix_rm "$test_dir"
    [ "$status" -eq 0 ]
    [ ! -d "$test_dir" ]
}

@test "posix_rm handles empty path" {
    run posix_rm ""
    [ "$status" -eq 1 ]
}

@test "posix_cp copies file successfully" {
    local src_file="/tmp/test_posix_cp_src_$(date +%s).txt"
    local dest_file="/tmp/test_posix_cp_dest_$(date +%s).txt"
    
    echo "test content" > "$src_file"
    run posix_cp "$src_file" "$dest_file"
    [ "$status" -eq 0 ]
    [ -f "$dest_file" ]
    [ "$(cat "$dest_file")" = "test content" ]
    
    rm -f "$src_file" "$dest_file"
}

@test "posix_cp copies directory successfully" {
    local src_dir="/tmp/test_posix_cp_src_dir_$(date +%s)"
    local dest_dir="/tmp/test_posix_cp_dest_dir_$(date +%s)"
    
    mkdir -p "$src_dir"
    echo "test content" > "$src_dir/test_file.txt"
    run posix_cp "$src_dir" "$dest_dir"
    [ "$status" -eq 0 ]
    [ -d "$dest_dir" ]
    [ -f "$dest_dir/test_file.txt" ]
    [ "$(cat "$dest_dir/test_file.txt")" = "test content" ]
    
    rm -rf "$src_dir" "$dest_dir"
}

@test "posix_cp handles non-existent source" {
    run posix_cp "/non/existent/path" "/tmp/dest"
    [ "$status" -eq 1 ]
}

@test "posix_mv moves file successfully" {
    local src_file="/tmp/test_posix_mv_src_$(date +%s).txt"
    local dest_file="/tmp/test_posix_mv_dest_$(date +%s).txt"
    
    echo "test content" > "$src_file"
    [ -f "$src_file" ]
    run posix_mv "$src_file" "$dest_file"
    [ "$status" -eq 0 ]
    [ ! -f "$src_file" ]
    [ -f "$dest_file" ]
    [ "$(cat "$dest_file")" = "test content" ]
    
    rm -f "$dest_file"
}

@test "posix_mv handles non-existent source" {
    run posix_mv "/non/existent/path" "/tmp/dest"
    [ "$status" -eq 1 ]
}

@test "posix_exists returns true for existing path" {
    local test_file="/tmp/test_posix_exists_$(date +%s).txt"
    touch "$test_file"
    run posix_exists "$test_file"
    [ "$status" -eq 0 ]
    rm -f "$test_file"
}

@test "posix_exists returns false for non-existent path" {
    run posix_exists "/non/existent/path"
    [ "$status" -eq 1 ]
}

@test "posix_is_directory returns true for directory" {
    local test_dir="/tmp/test_posix_is_dir_$(date +%s)"
    mkdir -p "$test_dir"
    run posix_is_directory "$test_dir"
    [ "$status" -eq 0 ]
    rm -rf "$test_dir"
}

@test "posix_is_directory returns false for file" {
    local test_file="/tmp/test_posix_is_dir_file_$(date +%s).txt"
    touch "$test_file"
    run posix_is_directory "$test_file"
    [ "$status" -eq 1 ]
    rm -f "$test_file"
}

@test "posix_is_file returns true for file" {
    local test_file="/tmp/test_posix_is_file_$(date +%s).txt"
    touch "$test_file"
    run posix_is_file "$test_file"
    [ "$status" -eq 0 ]
    rm -f "$test_file"
}

@test "posix_is_file returns false for directory" {
    local test_dir="/tmp/test_posix_is_file_dir_$(date +%s)"
    mkdir -p "$test_dir"
    run posix_is_file "$test_dir"
    [ "$status" -eq 1 ]
    rm -rf "$test_dir"
}