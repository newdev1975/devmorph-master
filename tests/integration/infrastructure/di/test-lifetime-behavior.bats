#!/usr/bin/env bats
# Test: test-lifetime-behavior.bats
# Description: Integration tests for lifetime management behavior

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/ServiceResolver.impl'
load '../../src/infrastructure/di/LifetimeManager.impl'
load '../../src/infrastructure/di/utils/DIUtils.impl'

setup() {
    # Initialize container before each test
    di_utils_initialize_container
}

teardown() {
    # Clean up after each test
    container_destroy
}

# Define a counter service to test lifetime behavior
CounterService() {
    # In a real implementation, this would maintain state
    # For this test, we'll just return a unique identifier
    echo "Counter-$$"
}

@test "singleton lifetime consistency across resolutions" {
    # Register as singleton
    run container_register "Counter" "CounterService" "singleton"
    [ "$status" -eq 0 ]
    
    # Get multiple instances
    run container_resolve "Counter"
    [ "$status" -eq 0 ]
    instance1="$output"
    
    run container_resolve "Counter"
    [ "$status" -eq 0 ]
    instance2="$output"
    
    run container_resolve "Counter"
    [ "$status" -eq 0 ]
    instance3="$output"
    
    # All should be the same instance
    [ "$instance1" = "$instance2" ]
    [ "$instance2" = "$instance3" ]
    
    # Test that clearing instances works
    run lifetime_manager_clear_singletons
    [ "$status" -eq 0 ]
    
    # Now we should get a different instance
    run container_resolve "Counter"
    [ "$status" -eq 0 ]
    instance4="$output"
    
    # This should be different from the previous ones
    [ "$instance1" != "$instance4" ]
}

@test "scoped lifetime works with different scopes" {
    # Register as scoped
    run container_register "ScopedCounter" "CounterService" "scoped"
    [ "$status" -eq 0 ]
    
    # Set first scope
    run container_set_scope "scope1"
    [ "$status" -eq 0 ]
    
    run container_resolve "ScopedCounter"
    [ "$status" -eq 0 ]
    scope1_instance1="$output"
    
    run container_resolve "ScopedCounter"
    [ "$status" -eq 0 ]
    scope1_instance2="$output"
    
    # Same scope, same instance
    [ "$scope1_instance1" = "$scope1_instance2" ]
    
    # Set second scope
    run container_set_scope "scope2"
    [ "$status" -eq 0 ]
    
    run container_resolve "ScopedCounter"
    [ "$status" -eq 0 ]
    scope2_instance1="$output"
    
    # Different scope, different instance
    [ "$scope1_instance1" != "$scope2_instance1" ]
    
    # Same scope again, same instance
    run container_resolve "ScopedCounter"
    [ "$status" -eq 0 ]
    scope2_instance2="$output"
    
    [ "$scope2_instance1" = "$scope2_instance2" ]
    
    # Clear specific scope
    run lifetime_manager_clear_scope "scope1"
    [ "$status" -eq 0 ]
    
    # Get new instance for scope1
    run container_set_scope "scope1"
    [ "$status" -eq 0 ]
    
    run container_resolve "ScopedCounter"
    [ "$status" -eq 0 ]
    scope1_instance3="$output"
    
    # Should be different from the original
    [ "$scope1_instance1" != "$scope1_instance3" ]
}

@test "lifetime manager statistics work correctly" {
    # Register services with different lifetimes
    run container_register "Singleton1" "CounterService" "singleton"
    [ "$status" -eq 0 ]
    
    run container_register "Singleton2" "CounterService" "singleton"
    [ "$status" -eq 0 ]
    
    # Resolve to create instances
    run container_resolve "Singleton1"
    [ "$status" -eq 0 ]
    
    run container_resolve "Singleton2"
    [ "$status" -eq 0 ]
    
    # Check stats
    run lifetime_manager_get_stats
    [ "$status" -eq 0 ]
    [[ "$output" = *"Singleton instances: 2"* ]]
}