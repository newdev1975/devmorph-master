#!/usr/bin/env bats
# Test: test-complex-service-resolution.bats
# Description: Integration tests for complex service resolution with dependencies

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/ServiceResolver.impl'
load '../../src/infrastructure/di/LifetimeManager.impl'
load '../../src/infrastructure/di/factories/ServiceFactory.impl'
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

# Define mock services for dependency testing
DatabaseConnection() {
    echo "DatabaseConnection-$$"
}

UserService() {
    # This service expects dependencies to be passed as arguments
    echo "UserService-$$"
}

LoggerService() {
    echo "LoggerService-$$"
}

@test "complex service resolution with dependencies works" {
    # Register services
    run container_register "Logger" "LoggerService" "singleton"
    [ "$status" -eq 0 ]
    
    run container_register "Database" "DatabaseConnection" "singleton"
    [ "$status" -eq 0 ]
    
    # Register UserService with dependencies
    run container_register "User" "UserService" "transient"
    [ "$status" -eq 0 ]
    
    # Set up dependencies for UserService
    run set_service_dependencies "UserService" "Logger" "Database"
    [ "$status" -eq 0 ]
    
    # Resolve the service with dependencies
    run container_resolve "User"
    [ "$status" -eq 0 ]
    
    # We expect this to work without circular dependency issues
}

@test "lifetime behavior works correctly in integration" {
    # Register services with different lifetimes
    run container_register "SingletonService" "LoggerService" "singleton"
    [ "$status" -eq 0 ]
    
    run container_register "TransientService" "DatabaseConnection" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "ScopedService" "UserService" "scoped"
    [ "$status" -eq 0 ]
    
    # Test singleton behavior
    run container_resolve "SingletonService"
    [ "$status" -eq 0 ]
    singleton1="$output"
    
    run container_resolve "SingletonService"
    [ "$status" -eq 0 ]
    singleton2="$output"
    
    [ "$singleton1" = "$singleton2" ]
    
    # Test transient behavior
    run container_resolve "TransientService"
    [ "$status" -eq 0 ]
    transient1="$output"
    
    run container_resolve "TransientService"
    [ "$status" -eq 0 ]
    transient2="$output"
    
    [ "$transient1" != "$transient2" ]
    
    # Test scoped behavior
    run container_set_scope "scope1"
    [ "$status" -eq 0 ]
    
    run container_resolve "ScopedService"
    [ "$status" -eq 0 ]
    scoped1_1="$output"
    
    run container_resolve "ScopedService"
    [ "$status" -eq 0 ]
    scoped1_2="$output"
    
    [ "$scoped1_1" = "$scoped1_2" ]
    
    run container_set_scope "scope2"
    [ "$status" -eq 0 ]
    
    run container_resolve "ScopedService"
    [ "$status" -eq 0 ]
    scoped2_1="$output"
    
    [ "$scoped1_1" != "$scoped2_1" ]
}

@test "factory pattern works in integration" {
    # Create a factory
    run service_factory_create "ConfigFactory" "UserService" "default_config"
    [ "$status" -eq 0 ]
    
    # Use the factory to get a service
    run service_factory_get "ConfigFactory" "param1" "param2"
    [ "$status" -eq 0 ]
}

@test "dependency chain validation works" {
    # Register services with dependencies
    run container_register "ServiceA" "UserService" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "ServiceB" "LoggerService" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "ServiceC" "DatabaseConnection" "transient"
    [ "$status" -eq 0 ]
    
    # Set up dependency chain: A -> B -> C
    run set_service_dependencies "UserService" "ServiceB"
    [ "$status" -eq 0 ]
    
    run set_service_dependencies "LoggerService" "ServiceC"
    [ "$status" -eq 0 ]
    
    # Validate the dependency chain
    run validate_dependency_chain "ServiceA"
    [ "$status" -eq 0 ]
    
    # Resolve service A (which should resolve B and C)
    run container_resolve "ServiceA"
    [ "$status" -eq 0 ]
}