#!/bin/sh
# Test to load all DI components and validate function availability

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

echo "Shell utilities loaded successfully"

# Source the container implementation
if [ -f "./Container.impl" ]; then
    . ./Container.impl
else
    echo "ERROR: Container.impl not found" >&2
    exit 1
fi

echo "Container loaded successfully"

# Source the service registry
if [ -f "./ServiceRegistry.impl" ]; then
    . ./ServiceRegistry.impl
else
    echo "ERROR: ServiceRegistry.impl not found" >&2
    exit 1
fi

echo "ServiceRegistry loaded successfully"

# Source the service resolver
if [ -f "./ServiceResolver.impl" ]; then
    . ./ServiceResolver.impl
else
    echo "ERROR: ServiceResolver.impl not found" >&2
    exit 1
fi

echo "ServiceResolver loaded successfully"

# Source the lifetime manager
if [ -f "./LifetimeManager.impl" ]; then
    . ./LifetimeManager.impl
else
    echo "ERROR: LifetimeManager.impl not found" >&2
    exit 1
fi

echo "LifetimeManager loaded successfully"

# Source the circular dependency detector
if [ -f "./CircularDependencyDetector.impl" ]; then
    . ./CircularDependencyDetector.impl
else
    echo "ERROR: CircularDependencyDetector.impl not found" >&2
    exit 1
fi

echo "CircularDependencyDetector loaded successfully"

# Source the exception handling
if [ -f "./exceptions/ExceptionHandling.impl" ]; then
    . ./exceptions/ExceptionHandling.impl
else
    echo "ERROR: ExceptionHandling.impl not found" >&2
    exit 1
fi

echo "ExceptionHandling loaded successfully"

# Source the factory implementation
if [ -f "./factories/ServiceFactory.impl" ]; then
    . ./factories/ServiceFactory.impl
else
    echo "ERROR: ServiceFactory.impl not found" >&2
    exit 1
fi

echo "ServiceFactory loaded successfully"

# Source the DI utilities
if [ -f "./utils/DIUtils.impl" ]; then
    . ./utils/DIUtils.impl
else
    echo "ERROR: DIUtils.impl not found" >&2
    exit 1
fi

echo "DIUtils loaded successfully"

# Check if all required functions are available
if ! command -v validate_binding >/dev/null 2>&1; then
    echo "ERROR: validate_binding function not available" >&2
    exit 1
fi

if ! command -v container_init >/dev/null 2>&1; then
    echo "ERROR: container_init function not available" >&2
    exit 1
fi

if ! command -v container_register >/dev/null 2>&1; then
    echo "ERROR: container_register function not available" >&2
    exit 1
fi

echo "All functions available"

# Run basic initialization test
echo "Testing container initialization..."
container_init || exit 1
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