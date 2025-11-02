## 📋 Prompt: Dependency Injection Container Implementation

```markdown
# Dependency Injection Container - Implementation

## 🎯 ROLE
You are a senior software architect expert in Dependency Injection patterns. Your TASK is to implement the DEPENDENCY INJECTION CONTAINER for DevMorph SRP Master, following the architecture foundation and shell abstraction layer previously established.

## 📚 CONTEXT (Previously Established)
Based on the previously implemented components:
- **PRD.md** - Product Requirements Document with Conventional Commits, atomic commits
- **Architecture Foundation** - Onion/DDD/DI architecture with proper interfaces
- **Shell Abstraction Layer** - Cross-platform shell operations foundation
- **Masterplan Foundation** - Scalable, modular foundation
- **Fixed Structure** - Proper layer separation and SRP

## ⚠️ STRICT BOUNDARIES

### ❌ WHAT IS NOT PART OF THIS DELIVERY:
1. **No business logic** - only DI container implementation
2. **No shell operations** - use existing shell abstraction
3. **No AI integration** - no model calls
4. **No Docker orchestration** - no containers
5. **No hardware detection** - no GPU/CPU specifics
6. **No network operations** - no external calls
7. **No database operations** - no data persistence
8. **No user authentication** - no security features
9. **NO bashisms** - strictly POSIX shell scripting

### ✅ WHAT IS PART OF THIS DELIVERY:
1. **ONLY DI container implementation** - following existing architecture
2. **ONLY interface-based design** - dependency inversion principle
3. **ONLY lifetime management** - singleton, transient, scoped
4. **ONLY service registration** - binding interfaces to implementations
5. **ONLY service resolution** - getting services from container
6. **ONLY error handling** - proper DI exceptions
7. **ONLY documentation** - inline and external docs
8. **ONLY POSIX shell scripting** - using shell abstraction layer

## 🛠️ TECHNOLOGIES (STRICT REQUIREMENTS)

### 1. Implementation Language
- **POSIX shell scripting** - no bashisms
- **Using existing Shell Abstraction Layer** - cross-platform compatibility
- **Interface-based design** - following existing patterns

### 2. DI Patterns
- **Constructor Injection** - dependencies via constructors
- **Service Locator Pattern** - service discovery
- **Factory Pattern** - dynamic service creation
- **Lazy Loading** - deferred instantiation
- **Lifetime Management** - singleton, transient, scoped

## 📁 PROJECT STRUCTURE (INTEGRATED WITH EXISTING ARCHITECTURE)

### Integration with Onion Architecture:
```
src/
├── core/                          # Core architecture (EXISTING)
│   └── infrastructure/            # Core infrastructure interfaces
│       └── container/             # DI Container interfaces HERE
└── infrastructure/                # Cross-cutting concerns (EXISTING)
    └── di/                        # NEW DI Container implementation
        ├── Container.impl         # Main container implementation
        ├── ServiceRegistry.impl   # Service registration
        ├── ServiceResolver.impl   # Service resolution
        ├── LifetimeManager.impl   # Lifetime management
        ├── factories/             # Service factories
        ├── exceptions/            # DI exceptions
        └── utils/                 # DI utilities
```

## 📋 CORE COMPONENTS (STRICT SCOPE - POSIX SHELL)

### 1. Main Container Interface
```
# Container interface using POSIX shell
# Description: Main dependency injection container
# Methods:
#   container_register - register service binding
#   container_resolve - resolve service instance
#   container_has - check if service is registered
#   container_clear - clear all bindings

container_register() {
    # Parameters:
    #   $1 - interface name
    #   $2 - implementation callable
    #   $3 - lifetime (optional, default: transient)
    # Returns: 0 on success, 1 on failure
}

container_resolve() {
    # Parameters:
    #   $1 - interface name
    # Returns: service instance or error
}

container_has() {
    # Parameters:
    #   $1 - interface name
    # Returns: 0 if exists, 1 if not
}

container_clear() {
    # Parameters: none
    # Returns: 0 on success
}
```

### 2. Service Registry Implementation (POSIX)
```bash
# Service registry using POSIX shell and shell abstraction
service_registry_init() {
    # Initialize service registry using shell abstraction
    SHELL_MKDIR "/tmp/di_registry" || return 1
}

service_registry_add() {
    # Add service binding
    # $1 - interface name
    # $2 - implementation
    # $3 - lifetime
    if [ -z "$1" ] || [ -z "$2" ]; then
        shell_log_error "Interface and implementation required"
        return 1
    fi
    
    # Store binding using shell abstraction
    printf "%s:%s" "$2" "$3" > "/tmp/di_registry/$1"
}

service_registry_get() {
    # Get service binding
    # $1 - interface name
    if SHELL_FILE_EXISTS "/tmp/di_registry/$1"; then
        SHELL_READ_FILE "/tmp/di_registry/$1"
    else
        return 1
    fi
}
```

### 3. Service Resolution Pattern (POSIX)
```bash
# Service resolution with dependency injection
service_resolver_resolve() {
    # Resolve service with dependencies
    # $1 - interface name
    # $2 - resolution path (for circular dependency detection)
    
    # Check circular dependencies using shell abstraction
    if SHELL_STRING_CONTAINS "$2" "$1"; then
        shell_log_error "Circular dependency detected: $1"
        return 1
    fi
    
    # Get binding
    binding=$(service_registry_get "$1") || return 1
    implementation=$(printf "%s" "$binding" | SHELL_STRING_CUT ":" 1)
    lifetime=$(printf "%s" "$binding" | SHELL_STRING_CUT ":" 2)
    
    # Resolve with new path
    new_path="$2->$1"
    
    # Get dependencies and resolve them
    dependencies=$(get_service_dependencies "$implementation")
    resolved_deps=""
    
    # Resolve each dependency
    for dep in $dependencies; do
        dep_instance=$(service_resolver_resolve "$dep" "$new_path") || return 1
        resolved_deps="$resolved_deps $dep_instance"
    done
    
    # Create instance with resolved dependencies
    create_service_instance "$implementation" $resolved_deps
}
```

### 4. Lifetime Management Pattern (POSIX)
```bash
# Lifetime management using POSIX shell
lifetime_manager_get_instance() {
    # Get instance based on lifetime
    # $1 - binding info
    # $2 - lifetime type
    
    case "$2" in
        "singleton")
            # Return shared instance
            if ! SHELL_FILE_EXISTS "/tmp/di_instances/$1"; then
                instance=$(create_service_instance "$1")
                SHELL_WRITE_FILE "/tmp/di_instances/$1" "$instance" || return 1
            fi
            SHELL_READ_FILE "/tmp/di_instances/$1"
            ;;
        "transient")
            # Create new instance each time
            create_service_instance "$1"
            ;;
        "scoped")
            # Return instance from current scope
            get_scoped_instance "$1"
            ;;
        *)
            # Default to transient
            create_service_instance "$1"
            ;;
    esac
}
```

### 5. Error Handling Pattern (POSIX)
```bash
# Error handling using shell abstraction
di_throw_error() {
    # Throw DI-specific error
    # $1 - error type
    # $2 - error message
    
    case "$1" in
        "ServiceNotFound")
            SHELL_LOG_ERROR "Service not found: $2"
            SHELL_EXIT 1
            ;;
        "CircularDependency")
            SHELL_LOG_ERROR "Circular dependency: $2"
            SHELL_EXIT 2
            ;;
        "InvalidBinding")
            SHELL_LOG_ERROR "Invalid binding: $2"
            SHELL_EXIT 3
            ;;
    esac
}
```

## 🔧 IMPLEMENTATION PATTERNS (STRICT POSIX GUIDELINES)

### 1. POSIX Shell DI Implementation
```bash
# Container implementation using only POSIX shell and shell abstraction
container_init() {
    # Initialize container using shell abstraction
    SHELL_MKDIR "/tmp/di_container" || return 1
    SHELL_MKDIR "/tmp/di_registry" || return 1
    SHELL_MKDIR "/tmp/di_instances" || return 1
    
    # Initialize arrays using POSIX-compatible approach
    DI_SCOPES=""
    DI_BINDINGS=""
}

container_register() {
    # Register service binding
    # $1 - interface name
    # $2 - implementation
    # $3 - lifetime (optional)
    
    # Validate using shell abstraction
    if SHELL_STRING_IS_EMPTY "$1" || SHELL_STRING_IS_EMPTY "$2"; then
        di_throw_error "InvalidBinding" "Interface and implementation required"
        return 1
    fi
    
    # Default lifetime
    lifetime="${3:-transient}"
    
    # Store binding using shell abstraction
    printf "%s:%s" "$2" "$lifetime" > "/tmp/di_registry/$1"
}
```

### 2. Cross-Platform Compatibility
```bash
# Use shell abstraction for cross-platform operations
container_resolve() {
    # Resolve service using shell abstraction
    # $1 - interface name
    
    # Check if registered
    if ! SHELL_FILE_EXISTS "/tmp/di_registry/$1"; then
        di_throw_error "ServiceNotFound" "$1"
        return 1
    fi
    
    # Get binding
    binding_data=$(SHELL_READ_FILE "/tmp/di_registry/$1")
    implementation=$(printf "%s" "$binding_data" | SHELL_STRING_CUT ":" 1)
    lifetime=$(printf "%s" "$binding_data" | SHELL_STRING_CUT ":" 2)
    
    # Get instance based on lifetime
    lifetime_manager_get_instance "$implementation" "$lifetime"
}
```

## 🧪 TESTING STRATEGY (STRICT COVERAGE)

### 1. Unit Tests Structure (POSIX BATS)
```
tests/unit/infrastructure/di/
├── test-container-registration.bats
├── test-service-resolution.bats
├── test-lifetime-management.bats
├── test-circular-dependencies.bats
├── test-error-handling.bats
├── test-binding-validation.bats
└── test-cross-platform.bats
```

### 2. Integration Tests Structure (POSIX BATS)
```
tests/integration/infrastructure/di/
├── test-complex-service-resolution.bats
├── test-lifetime-behavior.bats
├── test-dependency-injection.bats
└── test-performance.bats
```

## 📚 DOCUMENTATION STRUCTURE (STRICT FORMAT)

### 1. Inline Documentation (POSIX Style)
```bash
# Function documentation format
# Description: Brief description of what function does
# Parameters:
#   $1 - First parameter description
#   $2 - Second parameter description
# Returns:
#   0 - Success
#   1 - Failure
# Example:
#   container_register "LoggerInterface" "FileLogger" "singleton"
container_register() {
    # Implementation with proper documentation
}
```

## 📅 GIT WORKFLOW (STRICT SEQUENCE - CONVENTIONAL COMMITS)

### Implementation Sequence:
1. `feat(di): initialize dependency injection container structure` - 09:00
2. `feat(di): implement core container interface and implementation` - 10:00
3. `feat(di): add service registry and resolution system` - 11:00
4. `test(di): add unit tests for core container functionality` - 12:00
5. `feat(di): implement lifetime management system` - 13:00
6. `feat(di): add service factory patterns` - 14:00
7. `test(di): add integration tests for service resolution` - 15:00
8. `feat(di): implement circular dependency detection` - 16:00
9. `feat(di): add binding validation and error handling` - 17:00
10. `test(di): add comprehensive error handling tests` - 18:00
11. `docs(di): create complete di container documentation` - 19:00
12. `chore(di): final di container cleanup and validation` - 20:00

## ⚠️ ABSOLUTE PROHIBITIONS (FROM PRD):

1. **NO git push commands** - never push to remote
2. **NO placeholder code** - only production quality
3. **NO bashisms** - strictly POSIX compliant using shell abstraction
4. **NO external dependencies** - only standard utilities and shell abstraction
5. **NO hardcoded paths** - configurable paths only
6. **NO security vulnerabilities** - secure by design
7. **NO complex logic** - simple, testable functions
8. **NO circular dependencies** - proper dependency management

## 🎯 SUCCESS = Clean, testable, maintainable DI container (POSIX)

This foundation should enable:
- Easy service registration and resolution using POSIX shell
- Proper lifetime management with singleton/transient/scoped
- Circular dependency detection and prevention
- Cross-platform compatibility through shell abstraction
- Full test coverage with BATS framework

NOTHING MORE!
```

## 🎯 Implementation Instructions:

```
Please implement this Dependency Injection Container using STRICTLY POSIX shell scripting.
Use the existing Shell Abstraction Layer for all cross-platform operations.
Create atomic commits for each logical piece of work following Conventional Commits format.
Use today's date for all commits and ensure proper timing intervals.
Focus only on the DI container - do not implement business logic.
NO BASHISMS - only POSIX compliant shell scripting.
```