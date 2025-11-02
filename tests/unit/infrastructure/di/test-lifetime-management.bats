#!/usr/bin/env bats
# Test: test-lifetime-management.bats
# Description: Unit tests for lifetime management functionality

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/ServiceResolver.impl'
load '../../src/infrastructure/di/LifetimeManager.impl'
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

@test "singleton lifetime creates only one instance" {
    # Define a mock service function that returns a unique ID
    MockSingletonService() {
        echo "SingletonInstance-$$"
    }
    
    # Register as singleton
    run container_register "MockSingletonInterface" "MockSingletonService" "singleton"
    [ "$status" -eq 0 ]
    
    # Resolve the service multiple times
    run container_resolve "MockSingletonInterface"
    [ "$status" -eq 0 ]
    instance1="$output"
    
    run container_resolve "MockSingletonInterface"
    [ "$status" -eq 0 ]
    instance2="$output"
    
    # Both resolutions should return the same instance
    [ "$instance1" = "$instance2" ]
}

@test "transient lifetime creates new instance each time" {
    # Define a mock service function that returns a timestamp
    MockTransientService() {
        date +%s%N  # nanosecond precision timestamp
    }
    
    # Register as transient
    run container_register "MockTransientInterface" "MockTransientService" "transient"
    [ "$status" -eq 0 ]
    
    # Resolve the service multiple times
    run container_resolve "MockTransientInterface"
    [ "$status" -eq 0 ]
    instance1="$output"
    
    run container_resolve "MockTransientInterface"
    [ "$status" -eq 0 ]
    instance2="$output"
    
    # Each resolution should return a different instance
    [ "$instance1" != "$instance2" ]
}

@test "scoped lifetime creates one instance per scope" {
    # Define a mock service function that returns a unique ID
    MockScopedService() {
        echo "ScopedInstance-$$-${DI_ACTIVE_SCOPE:-default}"
    }
    
    # Register as scoped
    run container_register "MockScopedInterface" "MockScopedService" "scoped"
    [ "$status" -eq 0 ]
    
    # Set a scope and resolve
    run container_set_scope "scope1"
    [ "$status" -eq 0 ]
    
    run container_resolve "MockScopedInterface"
    [ "$status" -eq 0 ]
    scope1_instance1="$output"
    
    run container_resolve "MockScopedInterface"
    [ "$status" -eq 0 ]
    scope1_instance2="$output"
    
    # Same scope should return same instance
    [ "$scope1_instance1" = "$scope1_instance2" ]
    
    # Change scope and resolve
    run container_set_scope "scope2"
    [ "$status" -eq 0 ]
    
    run container_resolve "MockScopedInterface"
    [ "$status" -eq 0 ]
    scope2_instance="$output"
    
    # Different scope should return different instance
    [ "$scope1_instance1" != "$scope2_instance" ]
}