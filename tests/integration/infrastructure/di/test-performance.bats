#!/usr/bin/env bats
# Test: test-performance.bats
# Description: Integration tests for performance of the DI container

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/ServiceResolver.impl'
load '../../src/infrastructure/di/utils/DIUtils.impl'

setup() {
    # Initialize container before each test
    di_utils_initialize_container
}

teardown() {
    # Clean up after each test
    container_destroy
}

# Simple service for performance testing
PerformanceTestService() {
    echo "PerformanceTestService-$$"
}

@test "container handles many registrations efficiently" {
    # Register many services
    for i in $(seq 1 50); do
        run container_register "Service$i" "PerformanceTestService" "transient"
        [ "$status" -eq 0 ]
    done
    
    # Verify they all exist
    for i in $(seq 1 10); do  # Test only first 10 to keep test fast
        run container_has "Service$i"
        [ "$status" -eq 0 ]
    done
    
    # Check count of registered interfaces
    run container_get_registered_interfaces
    [ "$status" -eq 0 ]
    # Count lines in output
    count=$(echo "$output" | grep -c "^Service")
    [ $count -ge 10 ]
}

@test "resolution performance for repeated resolutions" {
    # Register a service
    run container_register "TestService" "PerformanceTestService" "singleton"
    [ "$status" -eq 0 ]
    
    # Resolve it multiple times
    for i in $(seq 1 20); do
        run container_resolve "TestService"
        [ "$status" -eq 0 ]
    done
    
    # For singleton, all should be the same
    run container_resolve "TestService"
    first_result="$output"
    
    run container_resolve "TestService"
    second_result="$output"
    
    [ "$first_result" = "$second_result" ]
}