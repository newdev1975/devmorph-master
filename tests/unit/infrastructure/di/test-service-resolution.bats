#!/usr/bin/env bats
# Test: test-service-resolution.bats
# Description: Unit tests for service resolution functionality

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/ServiceRegistry.impl'
load '../../src/infrastructure/di/ServiceResolver.impl'
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
        if [ -f "../../src/infrastructure/di/ServiceResolver.impl" ]; then
            . "../../src/infrastructure/di/ServiceResolver.impl"
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

@test "container_resolve returns error for unregistered service" {
    run container_resolve "NonExistentService"
    [ "$status" -ne 0 ]
}

@test "container_resolve works for simple service without dependencies" {
    # Define a mock service function
    MockService() {
        echo "MockServiceInstance"
    }
    
    # Register the mock service
    run container_register "MockServiceInterface" "MockService" "transient"
    [ "$status" -eq 0 ]
    
    # Resolve the service
    run container_resolve "MockServiceInterface"
    [ "$status" -eq 0 ]
    [ "$output" = "MockServiceInstance" ]
}
