# ADR 004: Dependency Injection Container

## Status
Accepted

## Context
Need inversion of control for loose coupling and testability.

Requirements:
- Service registration (interfaces to implementations)
- Dependency resolution (constructor injection)
- Lifetime management (singleton, transient, scoped)
- Circular dependency detection
- POSIX-compliant implementation

## Decision
Implement lightweight DI Container in pure POSIX sh.

### Architecture
```
┌─────────────────────────────────────┐
│        Container (Facade)           │
├─────────────────────────────────────┤
│    ServiceRegistry (Registration)   │
├─────────────────────────────────────┤
│    ServiceResolver (Resolution)     │
├─────────────────────────────────────┤
│   LifetimeManager (Scoping)         │
└─────────────────────────────────────┘
```

### Core Concepts

**Service Registration:**
- Interface → Implementation mapping
- Factory functions for complex construction
- Dependency declarations

**Lifetime Management:**
- **Singleton**: One instance per container
- **Transient**: New instance every time
- **Scoped**: One instance per scope (e.g., per request)

**Dependency Resolution:**
- Automatic dependency injection
- Constructor parameter resolution
- Circular dependency detection

## Implementation Strategy

### No Associative Arrays (POSIX Limitation)
Since POSIX sh doesn't support associative arrays, we use:
- File-based storage (tmp files for registry)
- Positional parameters for lists
- Delimited strings for key-value pairs

### Service Registry Format
```
# File: /tmp/di_registry_$$
interface_name|implementation_path|lifetime|dependencies
Example:
Logger.interface|Logger.impl|singleton|
UserService.interface|UserService.impl|transient|Logger.interface,Database.interface
```

### Resolution Algorithm
1. Check if service registered
2. Check lifetime (return cached if singleton)
3. Resolve dependencies (recursive)
4. Detect circular dependencies (stack tracking)
5. Instantiate service
6. Cache if singleton
7. Return instance

## Consequences

### Positive
- Loose coupling between components
- Easy to test (mock dependencies)
- SOLID compliance (Dependency Inversion Principle)
- Runtime configuration
- Single Responsibility (DI concerns separated)

### Negative
- Performance overhead vs direct instantiation
- File I/O for registry (POSIX limitation)
- Complexity for simple cases
- Debugging can be harder

### Limitations
- POSIX sh limitations (no associative arrays)
- File-based registry (not in-memory like OOP languages)
- String parsing overhead
- No compile-time validation

## Testing Strategy
- Unit tests for each component
- Integration tests for full container
- Circular dependency detection tests
- Lifetime management tests
- Performance benchmarks

## References
- Martin Fowler: Inversion of Control Containers
- SOLID Principles (Dependency Inversion)
- Hexagonal Architecture (Ports & Adapters)
