#!/bin/sh
# Integration test for DI Container

# Source the shell utilities
if [ -f "./shell_utils.sh" ]; then
    . ./shell_utils.sh
elif [ -f "../adapters/shell/shell_utils.sh" ]; then
    . ../adapters/shell/shell_utils.sh
elif [ -f "../../infrastructure/adapters/shell/shell_utils.sh" ]; then
    . ../../infrastructure/adapters/shell/shell_utils.sh
else
    echo "ERROR: shell_utils.sh not found" >&2
    exit 1
fi

# Source all DI components
. ./Container.impl
. ./ServiceRegistry.impl 
. ./ServiceResolver.impl
. ./LifetimeManager.impl
. ./CircularDependencyDetector.impl
. ./exceptions/ExceptionHandling.impl
. ./factories/ServiceFactory.impl
. ./utils/DIUtils.impl

# Test the full initialization utility
echo "Testing DI utilities initialization..."
di_utils_initialize_container || exit 1

echo "Container initialized successfully"

# Test valid registration - using format that passes validation
echo "Testing valid service registration..."
container_register "LoggerService" "logger.impl" "singleton"
echo "Logger service registered"

container_register "DatabaseService" "database.impl" "transient"
echo "Database service registered"

container_register "UserService" "user.impl" "scoped"
echo "User service registered"

# Test has functionality
echo "Testing service existence checks..."
container_has "LoggerService"
if [ $? -eq 0 ]; then
    echo "LoggerService exists"
else
    echo "ERROR: LoggerService should exist"
    exit 1
fi

container_has "NonExistentService"
if [ $? -ne 0 ]; then
    echo "NonExistentService correctly does not exist"
else
    echo "ERROR: NonExistentService should not exist"
    exit 1
fi

# Test set scope
echo "Testing scope functionality..."
container_set_scope "test_scope"
echo "Scope set to: $DI_ACTIVE_SCOPE"

# Test getting registered interfaces
echo "Testing getting registered interfaces..."
registered_services=$(container_get_registered_interfaces)
echo "Registered services: $registered_services"

# Test resolution with a simple mock function
MockService() {
    echo "MockServiceInstance-$$"
}

container_register "MockServiceInterface" "MockService" "transient"
resolved=$(container_resolve "MockServiceInterface")
echo "Resolved service: $resolved"

# Clean up
container_destroy
echo "Integration test completed successfully"