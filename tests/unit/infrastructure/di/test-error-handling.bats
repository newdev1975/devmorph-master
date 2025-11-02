#!/usr/bin/env bats
# Test: test-error-handling.bats
# Description: Unit tests for error handling functionality

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/exceptions/ExceptionHandling.impl'
load '../../src/infrastructure/di/utils/DIUtils.impl'

setup() {
    # Initialize container before each test
    di_utils_initialize_container
}

teardown() {
    # Clean up after each test
    container_destroy
}

@test "validate_binding returns error for invalid interface names" {
    run validate_binding "Invalid@Interface" "ValidImplementation"
    [ "$status" -ne 0 ]
    
    run validate_binding "Valid_Interface" "ValidImplementation"
    [ "$status" -eq 0 ]
}

@test "validate_binding returns error for invalid implementations" {
    run validate_binding "ValidInterface" "Invalid@Implementation"
    [ "$status" -ne 0 ]
    
    run validate_binding "ValidInterface" "ValidImplementation"
    [ "$status" -eq 0 ]
}

@test "validate_binding returns error for invalid lifetimes" {
    run validate_binding "ValidInterface" "ValidImplementation" "invalid_lifetime"
    [ "$status" -ne 0 ]
    
    run validate_binding "ValidInterface" "ValidImplementation" "singleton"
    [ "$status" -eq 0 ]
    
    run validate_binding "ValidInterface" "ValidImplementation" "transient"
    [ "$status" -eq 0 ]
    
    run validate_binding "ValidInterface" "ValidImplementation" "scoped"
    [ "$status" -eq 0 ]
}

@test "di_log_error logs errors without exiting" {
    run di_log_error "InvalidBinding" "Test error message"
    [ "$status" -eq 0 ]
}