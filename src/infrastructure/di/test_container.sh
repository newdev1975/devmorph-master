#!/bin/sh
# Simple test for DI Container

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

# Source the container implementation
if [ -f "./Container.impl" ]; then
    . ./Container.impl
else
    echo "ERROR: Container.impl not found" >&2
    exit 1
fi

# Source the service registry
if [ -f "./ServiceRegistry.impl" ]; then
    . ./ServiceRegistry.impl
else
    echo "ERROR: ServiceRegistry.impl not found" >&2
    exit 1
fi

# Source the exception handling
if [ -f "./exceptions/ExceptionHandling.impl" ]; then
    . ./exceptions/ExceptionHandling.impl
else
    echo "ERROR: ExceptionHandling.impl not found" >&2
    exit 1
fi

# Run basic test
echo "Testing container initialization..."
container_init
echo "DI registry dir: $DI_REGISTRY_DIR"
echo "DI instances dir: $DI_INSTANCES_DIR"
echo "DI scopes dir: $DI_SCOPES_DIR"

# Test registration
echo "Testing registration..."
container_register "TestService" "TestImpl" "singleton"
echo "Registration completed"

# Clean up
container_destroy
echo "Test completed successfully"