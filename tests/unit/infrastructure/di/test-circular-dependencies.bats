#!/usr/bin/env bats
# Test: test-circular-dependencies.bats
# Description: Unit tests for circular dependency detection

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/ServiceResolver.impl'
load '../../src/infrastructure/di/CircularDependencyDetector.impl'
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

@test "circular dependency detection prevents circular references" {
    # Register services that would have circular dependencies
    run container_register "ServiceA" "ServiceAImpl" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "ServiceB" "ServiceBImpl" "transient"
    [ "$status" -eq 0 ]
    
    # Set up dependencies: A depends on B, B depends on A (circular)
    run set_service_dependencies "ServiceAImpl" "ServiceB"
    [ "$status" -eq 0 ]
    
    run set_service_dependencies "ServiceBImpl" "ServiceA"
    [ "$status" -eq 0 ]
    
    # Try to resolve A - this should detect circular dependency
    run circular_aware_resolve "ServiceA"
    [ "$status" -ne 0 ]
    [[ "$output" = *"circular dependency detected"* ]]
}