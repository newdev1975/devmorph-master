#!/usr/bin/env bats
# Test: test-container-registration.bats
# Description: Unit tests for core container registration functionality

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/exceptions/ExceptionHandling.impl'
load '../../src/infrastructure/di/utils/DIUtils.impl'

setup() {
    # Initialize container before each test
    if command -v di_utils_initialize_container >/dev/null 2>&1; then
        di_utils_initialize_container
    else
        # Manually initialize if utils not loaded yet
        if [ -f "../../src/infrastructure/adapters/shell/shell_utils.sh" ]; then
            . "../../src/infrastructure/adapters/shell/shell_utils.sh"
        fi
        if [ -f "../../src/infrastructure/di/Container.impl" ]; then
            . "../../src/infrastructure/di/Container.impl"
        fi
        if [ -f "../../src/infrastructure/di/ServiceRegistry.impl" ]; then
            . "../../src/infrastructure/di/ServiceRegistry.impl"
        fi
        if [ -f "../../src/infrastructure/di/exceptions/ExceptionHandling.impl" ]; then
            . "../../src/infrastructure/di/exceptions/ExceptionHandling.impl"
        fi
        container_init
        service_registry_init
    fi
}

teardown() {
    # Clean up after each test
    if command -v container_destroy >/dev/null 2>&1; then
        container_destroy
    fi
}

@test "container_init successfully creates container directories" {
    run container_init
    [ "$status" -eq 0 ]
    [ -d "$DI_REGISTRY_DIR" ]
    [ -d "$DI_INSTANCES_DIR" ]
    [ -d "$DI_SCOPES_DIR" ]
}

@test "container_register adds service binding successfully" {
    run container_register "TestService" "TestImplementation" "singleton"
    [ "$status" -eq 0 ]
    
    # Check if binding exists
    run container_has "TestService"
    [ "$status" -eq 0 ]
}

@test "container_register fails with missing parameters" {
    run container_register
    [ "$status" -ne 0 ]
    
    run container_register "TestService"
    [ "$status" -ne 0 ]
}

@test "container_register validates lifetime parameter" {
    run container_register "TestService" "TestImplementation" "invalid_lifetime"
    [ "$status" -ne 0 ]
    
    run container_register "TestService" "TestImplementation" "singleton"
    [ "$status" -eq 0 ]
    
    run container_register "TestService2" "TestImplementation" "transient"
    [ "$status" -eq 0 ]
    
    run container_register "TestService3" "TestImplementation" "scoped"
    [ "$status" -eq 0 ]
}

@test "container_register validates binding format" {
    # Valid format
    run container_register "ValidService" "ValidImplementation"
    [ "$status" -eq 0 ]
    
    # Invalid format (with invalid characters)
    run container_register "Invalid@Service" "ValidImplementation"
    [ "$status" -ne 0 ]
    
    run container_register "ValidService" "Invalid@Implementation"
    [ "$status" -ne 0 ]
}

@test "container_has returns correct status for registered/unregistered services" {
    # Service not registered
    run container_has "NonExistentService"
    [ "$status" -ne 0 ]
    
    # Register a service
    run container_register "TestService" "TestImplementation"
    [ "$status" -eq 0 ]
    
    # Check that it exists
    run container_has "TestService"
    [ "$status" -eq 0 ]
}

@test "container_get_registered_interfaces returns registered services" {
    # Initially empty
    run container_get_registered_interfaces
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    
    # Register a service
    run container_register "TestService1" "TestImplementation1"
    [ "$status" -eq 0 ]
    
    run container_register "TestService2" "TestImplementation2"
    [ "$status" -eq 0 ]
    
    # Check that both services are returned
    run container_get_registered_interfaces
    [ "$status" -eq 0 ]
    [[ "$output" = *"TestService1"* ]]
    [[ "$output" = *"TestService2"* ]]
}

@test "container_clear removes all bindings" {
    # Register some services
    run container_register "TestService1" "TestImplementation1"
    [ "$status" -eq 0 ]
    
    run container_register "TestService2" "TestImplementation2"
    [ "$status" -eq 0 ]
    
    # Verify they exist
    run container_has "TestService1"
    [ "$status" -eq 0 ]
    
    run container_has "TestService2"
    [ "$status" -eq 0 ]
    
    # Clear the container
    run container_clear
    [ "$status" -eq 0 ]
    
    # Verify they're gone
    run container_has "TestService1"
    [ "$status" -ne 0 ]
    
    run container_has "TestService2"
    [ "$status" -ne 0 ]
}

@test "container_set_scope sets active scope correctly" {
    run container_set_scope "test_scope"
    [ "$status" -eq 0 ]
    [ "$DI_ACTIVE_SCOPE" = "test_scope" ]
}

@test "container_set_scope validates scope format" {
    run container_set_scope "invalid@scope"
    [ "$status" -ne 0 ]
    
    run container_set_scope "valid_scope"
    [ "$status" -eq 0 ]
}
