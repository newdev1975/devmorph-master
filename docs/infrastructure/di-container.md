# Dependency Injection Container - Documentation

## Overview

The Dependency Injection (DI) Container is a core component of the DevMorph SRP Master architecture that provides a robust, cross-platform service container implementing the dependency injection pattern. The container follows POSIX shell standards and integrates with the existing shell abstraction layer.

## Architecture

The DI container follows the Onion/Domain-Driven Design with proper separation of concerns:

```
src/
├── infrastructure/
│   ├── di/                 # DI Container Implementation
│   │   ├── Container.impl           # Main container interface and implementation
│   │   ├── ServiceRegistry.impl     # Service registration system
│   │   ├── ServiceResolver.impl     # Service resolution with dependency injection
│   │   ├── LifetimeManager.impl     # Lifetime management (singleton, transient, scoped)
│   │   ├── CircularDependencyDetector.impl  # Circular dependency detection
│   │   ├── exceptions/              # Error handling utilities
│   │   │   └── ExceptionHandling.impl
│   │   ├── factories/               # Service factory patterns
│   │   │   └── ServiceFactory.impl
│   │   └── utils/                   # Utility functions
│   │       └── DIUtils.impl
```

## Core Components

### Container Implementation

The main container provides the core API for:
- Service registration: `container_register(interface, implementation, lifetime)`
- Service resolution: `container_resolve(interface)`
- Service existence check: `container_has(interface)`
- Container lifecycle management: `container_init()`, `container_destroy()`

### Service Registry

Manages service bindings:
- Add bindings: `service_registry_add(interface, implementation, lifetime)`
- Get bindings: `service_registry_get(interface)`
- Check existence: `service_registry_has(interface)`
- Clear registry: `service_registry_clear()`

### Service Resolution

Handles dependency injection and service creation:
- Resolve with dependencies: `service_resolver_resolve(interface)`
- Get dependencies: `get_service_dependencies(implementation)`
- Create instances: `create_service_instance(implementation, dependencies)`

### Lifetime Management

Manages service lifetimes:
- Singleton: One instance per container
- Transient: New instance per resolution
- Scoped: One instance per scope

## Usage Examples

### Basic Registration and Resolution

```bash
# Initialize container
di_utils_initialize_container

# Register a service
container_register "LoggerInterface" "FileLoggerImpl" "singleton"

# Resolve the service
logger_instance=$(container_resolve "LoggerInterface")

# Clean up
container_destroy
```

### Registration with Dependencies

```bash
# Register services with dependencies
di_utils_register_with_dependencies "UserService" "UserServiceImpl" "transient" "LoggerInterface" "DatabaseInterface"

# Or set dependencies separately
container_register "UserService" "UserServiceImpl" "transient"
set_service_dependencies "UserServiceImpl" "LoggerInterface" "DatabaseInterface"
```

### Working with Different Lifetimes

```bash
# Register singleton (one instance per container)
container_register "ConfigService" "ConfigImpl" "singleton"

# Register transient (new instance each time)
container_register "RequestHandler" "RequestHandlerImpl" "transient"

# Register scoped (one instance per scope)
container_register "SessionService" "SessionImpl" "scoped"
container_set_scope "user_session_123"
```

## Features

### 1. Cross-Platform Compatibility
- POSIX shell compliant
- Uses shell abstraction layer for platform-specific operations
- Works on Linux, macOS, Windows (with POSIX environment)

### 2. Lifetime Management
- Singleton: Shared instance across container
- Transient: New instance per resolution
- Scoped: Instance per scope context

### 3. Dependency Injection
- Constructor injection pattern
- Automatic dependency resolution
- Support for complex dependency graphs

### 4. Circular Dependency Detection
- Prevents circular reference issues
- Provides clear error messages
- Validates dependency chains

### 5. Error Handling
- Comprehensive validation
- Detailed error messages
- Graceful failure handling

### 6. Service Factory Patterns
- Abstract factory support
- Builder pattern implementation
- Parameterized service creation

## Error Handling

The container provides comprehensive error handling:

- `ServiceNotFound`: Service interface not registered
- `CircularDependency`: Circular reference detected
- `InvalidBinding`: Invalid service binding format
- `LifetimeError`: Issue with lifetime management
- `DependencyResolutionError`: Error resolving dependencies

## Testing

### Unit Tests
Located in `tests/unit/infrastructure/di/`:
- `test-container-registration.bats` - Core registration functionality
- `test-service-resolution.bats` - Service resolution
- `test-lifetime-management.bats` - Lifetime behavior
- `test-circular-dependencies.bats` - Circular dependency detection
- `test-error-handling.bats` - Error handling validation
- `test-binding-validation.bats` - Binding validation
- `test-cross-platform.bats` - Cross-platform compatibility

### Integration Tests
Located in `tests/integration/infrastructure/di/`:
- `test-complex-service-resolution.bats` - Complex dependency resolution
- `test-lifetime-behavior.bats` - Lifetime management integration
- `test-dependency-injection.bats` - Dependency injection
- `test-performance.bats` - Performance tests

## Utilities

### DIUtils
Helper functions for common operations:
- `di_utils_initialize_container()` - Initialize complete container
- `di_utils_register_with_dependencies()` - Register with dependencies
- `di_utils_get_container_stats()` - Get container statistics
- `di_utils_validate_container()` - Validate container state

## Best Practices

1. **Interface Naming**: Use PascalCase for interface names (e.g., `LoggerInterface`)
2. **Implementation Format**: Use `name.type` format for implementations (e.g., `FileLogger.impl`)
3. **Lifetime Selection**: 
   - Use `singleton` for shared resources like configuration or logging
   - Use `transient` for request-scoped objects
   - Use `scoped` for session-based objects
4. **Dependency Management**: Keep dependency graphs as flat as possible to avoid complexity
5. **Error Handling**: Always check return codes when performing container operations

## Limitations

1. **No Runtime Code Generation**: The container works with pre-defined implementations
2. **POSIX Shell Limitations**: Complex object-oriented patterns are limited by shell capabilities
3. **Performance**: More complex dependency graphs may have performance implications

## Security Considerations

1. The container creates temporary directories - ensure proper cleanup
2. Implementations are resolved as shell functions/commands - validate inputs
3. Dependencies are resolved at runtime - verify trustworthiness of registered services