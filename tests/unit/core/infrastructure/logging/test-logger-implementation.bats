#!/usr/bin/env bats
# test-logger-implementation.bats
# Unit tests for Logger implementation

# Source the logger implementation
setup() {
    source "$BATS_TEST_DIRNAME/../../../../../src/core/infrastructure/logging/Logger.impl"
}

@test "logger_create_should_create_logger_with_valid_parameters" {
    # Test creating a logger with valid parameters
    run logger_create "info" "stderr"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Check that the logger ID has the expected format
    [[ "$output" =~ ^logger_[0-9]+_[0-9]+$ ]]
}

@test "logger_create_should_create_logger_with_file_destination" {
    # Test creating a logger with file destination
    temp_log_file="/tmp/test_logger_$$"
    run logger_create "debug" "$temp_log_file"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Clean up
    rm -f "$temp_log_file"
}

@test "logger_create_should_fail_with_empty_parameters" {
    # Test that logger creation fails with empty level
    run logger_create "" "stderr"
    [ "$status" -eq 1 ]

    # Test that logger creation fails with empty destination
    run logger_create "info" ""
    [ "$status" -eq 1 ]

    # Test that logger creation fails with both empty
    run logger_create "" ""
    [ "$status" -eq 1 ]
}

@test "logger_create_should_fail_with_invalid_log_level" {
    # Test that logger creation fails with invalid log level
    run logger_create "invalid_level" "stderr"
    [ "$status" -eq 1 ]
}

@test "logger_debug_should_log_debug_message" {
    # Create a logger instance
    logger_id=$(logger_create "debug" "stdout")
    [ -n "$logger_id" ]
    
    # Test logging a debug message
    run logger_debug "$logger_id" "Test debug message"
    [ "$status" -eq 0 ]
}

@test "logger_info_should_log_info_message" {
    # Create a logger instance
    logger_id=$(logger_create "info" "stdout")
    [ -n "$logger_id" ]
    
    # Test logging an info message
    run logger_info "$logger_id" "Test info message"
    [ "$status" -eq 0 ]
}

@test "logger_warning_should_log_warning_message" {
    # Create a logger instance
    logger_id=$(logger_create "warning" "stdout")
    [ -n "$logger_id" ]
    
    # Test logging a warning message
    run logger_warning "$logger_id" "Test warning message"
    [ "$status" -eq 0 ]
}

@test "logger_error_should_log_error_message" {
    # Create a logger instance
    logger_id=$(logger_create "error" "stdout")
    [ -n "$logger_id" ]
    
    # Test logging an error message
    run logger_error "$logger_id" "Test error message"
    [ "$status" -eq 0 ]
}

@test "logger_should_respect_log_levels" {
    # Create a logger with info level
    logger_id=$(logger_create "info" "/tmp/test_log_$$")
    [ -n "$logger_id" ]
    
    # Debug message should not be logged (level too low)
    run logger_debug "$logger_id" "This should not appear due to level"
    [ "$status" -eq 0 ]  # Function should succeed but not output
    
    # Info message should be logged
    run logger_info "$logger_id" "This should appear"
    [ "$status" -eq 0 ]
    
    # Clean up
    rm -f "/tmp/test_log_$$"
}

@test "logger_should_fail_with_invalid_logger_id" {
    # Test all logging functions with invalid logger ID
    run logger_debug "invalid_id" "Test message"
    [ "$status" -ne 0 ]
    
    run logger_info "invalid_id" "Test message"
    [ "$status" -ne 0 ]
    
    run logger_warning "invalid_id" "Test message"
    [ "$status" -ne 0 ]
    
    run logger_error "invalid_id" "Test message"
    [ "$status" -ne 0 ]
}