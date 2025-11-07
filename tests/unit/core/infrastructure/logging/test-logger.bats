#!/usr/bin/env bats

setup() {
    source src/core/infrastructure/logging/Logger.interface
}

@test "logger_create_should_define_interface_with_success_status" {
    # Test interface definition: execution succeeds, but no output (no impl)
    run logger_create "INFO" "/tmp/test.log"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty output for interface
}

@test "logger_info_should_define_interface_with_success_status" {
    # Create test logger (mock identifier)
    logger_id="test_logger"

    # Test interface: execution succeeds, empty output
    run logger_info "$logger_id" "Test info message"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface; full impl later
}
