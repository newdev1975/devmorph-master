#!/usr/bin/env bats
# Test: test-dependency-injection.bats
# Description: Integration tests for dependency injection functionality

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/ServiceResolver.impl'
load '../../src/infrastructure/di/CircularDependencyDetector.impl'
load '../../src/infrastructure/di/utils/DIUtils.impl'

setup() {
    # Initialize container before each test
    di_utils_initialize_container
}

teardown() {
    # Clean up after each test
    container_destroy
}

# Define mock services for dependency injection testing
EmailService() {
    echo "EmailService-$$"
}

UserServiceWithDeps() {
    # This service depends on other services
    echo "UserServiceWithDeps-$$"
}

NotificationService() {
    # This service depends on both EmailService and UserService
    echo "NotificationService-$$"
}

@test "dependency injection resolves dependencies correctly" {
    # Register all services
    run container_register "Email" "EmailService" "singleton"
    [ "$status" -eq 0 ]
    
    run container_register "User" "UserServiceWithDeps" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "Notification" "NotificationService" "transient"
    [ "$status" -eq 0 ]
    
    # Set up dependencies: NotificationService depends on Email and User
    run set_service_dependencies "NotificationService" "Email" "User"
    [ "$status" -eq 0 ]
    
    # Resolve Notification service - this should resolve all dependencies
    run container_resolve "Notification"
    [ "$status" -eq 0 ]
}

@test "circular dependency detection prevents resolution" {
    # Register services that form a circular dependency
    run container_register "ServiceA" "UserServiceWithDeps" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "ServiceB" "EmailService" "transient"
    [ "$status" -eq 0 ]
    
    # Set up circular dependencies: A -> B -> A
    run set_service_dependencies "UserServiceWithDeps" "ServiceB"
    [ "$status" -eq 0 ]
    
    run set_service_dependencies "EmailService" "ServiceA"
    [ "$status" -eq 0 ]
    
    # Try to resolve ServiceA - this should detect circular dependency
    run circular_aware_resolve "ServiceA"
    [ "$status" -ne 0 ]
    
    # Should contain error about circular dependency
    [[ "$output" = *"circular dependency detected"* ]]
}

@test "dependency validation works for complete chains" {
    # Register services in a dependency chain: A -> B -> C
    run container_register "ServiceA" "UserServiceWithDeps" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "ServiceB" "EmailService" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "ServiceC" "NotificationService" "transient"
    [ "$status" -eq 0 ]
    
    # Set up dependencies: A -> B, B -> C
    run set_service_dependencies "UserServiceWithDeps" "ServiceB"
    [ "$status" -eq 0 ]
    
    run set_service_dependencies "EmailService" "ServiceC"
    [ "$status" -eq 0 ]
    
    # Validate complete dependency chain
    run validate_dependency_chain "ServiceA"
    [ "$status" -eq 0 ]
    
    # Validate that unregistered dependency is caught
    run set_service_dependencies "NotificationService" "NonExistentService"
    [ "$status" -eq 0 ]
    
    run validate_dependency_chain "ServiceC"
    [ "$status" -ne 0 ]
}