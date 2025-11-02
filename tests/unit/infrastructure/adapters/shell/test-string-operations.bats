#!/usr/bin/env bats
# Test: test-string-operations.bats
# Description: Unit tests for string operations

# Mock the log_error function
log_error() {
    echo "ERROR: $1" >&2
}

load '../../../../../src/infrastructure/adapters/shell/shell_utils.sh'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/POSIXStringOperations.impl'

@test "posix_trim removes leading and trailing whitespace" {
    run posix_trim "  test string  "
    [ "$output" = "test string" ]
}

@test "posix_trim handles empty string" {
    run posix_trim ""
    [ "$output" = "" ]
}

@test "posix_trim handles only whitespace" {
    run posix_trim "   "
    [ "$output" = "" ]
}

@test "posix_contains finds substring" {
    run posix_contains "hello world" "world"
    [ "$status" -eq 0 ]
}

@test "posix_contains returns false when substring not found" {
    run posix_contains "hello world" "goodbye"
    [ "$status" -eq 1 ]
}

@test "posix_contains handles empty strings" {
    run posix_contains "" "world"
    [ "$status" -eq 1 ]
    
    run posix_contains "hello" ""
    [ "$status" -eq 1 ]
}

@test "posix_replace replaces substring correctly" {
    run posix_replace "hello world world" "world" "earth"
    [ "$output" = "hello earth earth" ]
}

@test "posix_replace handles no matches" {
    run posix_replace "hello world" "goodbye" "earth"
    [ "$output" = "hello world" ]
}

@test "posix_replace handles empty search string" {
    run posix_replace "hello" "" "world"
    [ "$output" = "hello" ]
    [ "$status" -eq 0 ]  # Should return success status, just not replace anything
}

@test "posix_starts_with returns true when string starts with prefix" {
    run posix_starts_with "hello world" "hello"
    [ "$status" -eq 0 ]
}

@test "posix_starts_with returns false when string does not start with prefix" {
    run posix_starts_with "hello world" "goodbye"
    [ "$status" -eq 1 ]
}

@test "posix_starts_with handles empty strings" {
    run posix_starts_with "" "prefix"
    [ "$status" -eq 1 ]
    
    run posix_starts_with "hello" ""
    [ "$status" -eq 1 ]
}

@test "posix_ends_with returns true when string ends with suffix" {
    run posix_ends_with "hello world" "world"
    [ "$status" -eq 0 ]
}

@test "posix_ends_with returns false when string does not end with suffix" {
    run posix_ends_with "hello world" "goodbye"
    [ "$status" -eq 1 ]
}

@test "posix_ends_with handles empty strings" {
    run posix_ends_with "" "suffix"
    [ "$status" -eq 1 ]
    
    run posix_ends_with "hello" ""
    [ "$status" -eq 1 ]
}

@test "posix_to_upper converts lowercase to uppercase" {
    run posix_to_upper "hello"
    [ "$output" = "HELLO" ]
}

@test "posix_to_upper handles already uppercase" {
    run posix_to_upper "HELLO"
    [ "$output" = "HELLO" ]
}

@test "posix_to_upper handles mixed case" {
    run posix_to_upper "HeLLo"
    [ "$output" = "HELLO" ]
}

@test "posix_to_upper handles empty string" {
    run posix_to_upper ""
    [ "$output" = "" ]
}

@test "posix_to_lower converts uppercase to lowercase" {
    run posix_to_lower "HELLO"
    [ "$output" = "hello" ]
}

@test "posix_to_lower handles already lowercase" {
    run posix_to_lower "hello"
    [ "$output" = "hello" ]
}

@test "posix_to_lower handles mixed case" {
    run posix_to_lower "HeLLo"
    [ "$output" = "hello" ]
}

@test "posix_to_lower handles empty string" {
    run posix_to_lower ""
    [ "$output" = "" ]
}

@test "posix_length returns correct length" {
    run posix_length "hello"
    [ "$output" = "5" ]
}

@test "posix_length returns 0 for empty string" {
    run posix_length ""
    [ "$output" = "0" ]
}

@test "posix_length handles strings with spaces" {
    run posix_length "hello world"
    [ "$output" = "11" ]
}