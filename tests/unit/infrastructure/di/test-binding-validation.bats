#!/usr/bin/env bats
# Test: test-binding-validation.bats
# Description: Unit tests for binding validation functionality

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

@test "validate_can_resolve checks if service can be resolved" {
    # Unregistered service should fail validation
    run validate_can_resolve "UnregisteredService"
    [ "$status" -ne 0 ]
    
    # Register a service
    run container_register "TestService" "TestImplementation"
    [ "$status" -eq 0 ]
    
    # Now it should pass validation
    run validate_can_resolve "TestService"
    [ "$status" -eq 0 ]
}

@test "validate_container_state checks for proper initialization" {
    # After setup, container should be in valid state
    run validate_container_state
    [ "$status" -eq 0 ]
    
    # Modify container state to simulate invalid state
    unset DI_REGISTRY_DIR
    
    run validate_container_state
    [ "$status" -ne 0 ]
}

@test "container_get_binding returns correct binding information" {
    # Register a service
    run container_register "TestService" "TestImplementation" "singleton"
    [ "$status" -eq 0 ]
    
    # Get binding information
    run container_get_binding "TestService"
    [ "$status" -eq 0 ]
    [ "$output" = "TestImplementation:singleton" ]
    
    # Try to get binding for unregistered service
    run container_get_binding "UnregisteredService"
    [ "$status" -ne 0 ]
}