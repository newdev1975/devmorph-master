# Lifetime Management

## Overview
Lifetime Management in Dependency Injection determines how long instances live and when they are created and destroyed. Proper lifetime management is crucial for performance, memory usage, and correct application behavior.

## Instance Lifetimes

### Singleton
- **Description**: Single instance per container, created on first request
- **Use Case**: Stateless services, utilities, configuration providers
- **Benefits**: Memory efficient, shared state (when appropriate)
- **Considerations**: Thread safety required, global state concerns

```
container.registerSingleton(Logger, () => new FileLogger("app.log"))
container.registerSingleton(ConfigProvider, () => new EnvironmentConfigProvider())
```

### Transient
- **Description**: New instance created on each request
- **Use Case**: Stateful objects, request-scoped dependencies
- **Benefits**: No shared state, thread safety by design
- **Considerations**: Higher memory usage, potential performance impact

```
container.registerTransient(TemplateProcessor, () => new TemplateProcessor())
container.registerTransient(ValidationContext, () => new ValidationContext())
```

### Scoped
- **Description**: Single instance per scope (e.g., web request, session)
- **Use Case**: Request-scoped operations, database contexts
- **Benefits**: Balance between singleton and transient
- **Considerations**: Scope management complexity

```
container.registerScoped(DatabaseContext, () => new DatabaseContext())
container.registerScoped(RequestContext, () => new RequestContext())
```

## Lifecycle Events

### Creation Events
Objects may need to perform initialization when created:

```
interface Initializable {
    initialize()  // Called after injection is complete
}

class DatabaseService implements Initializable {
    initialize() {
        connectToDatabase()
        setupConnectionPooling()
    }
}
```

### Destruction Events
Objects may need cleanup when destroyed:

```
interface Disposable {
    dispose()  // Called before destruction
}

class FileHandler implements Disposable {
    dispose() {
        closeFileHandles()
        cleanupTempFiles()
    }
}
```

## Container Lifecycle Management

### Registration-Time Configuration
```
container.register(
    TemplateRepository,
    () => new FileTemplateRepository(),
    Lifetime.Singleton  // Specify lifetime at registration
)
```

### Factory-Based Lifecycle
```
class RepositoryFactory {
    create() {
        // Custom creation logic
        repo = new FileTemplateRepository()
        repo.initialize()
        return repo
    }
    
    destroy(repository) {
        // Custom destruction logic
        repository.cleanup()
    }
}
```

## Thread Safety Considerations

### Singleton Thread Safety
- Ensure stateless or thread-safe implementation
- Use thread-local storage if needed
- Consider immutable objects where possible

### Scope Isolation
- Ensure scopes don't leak between threads
- Proper scope context switching
- Thread-local scope management

## Memory Management

### Circular Dependencies
- Can prevent garbage collection
- Should be avoided through better design
- Container should detect and report circular dependencies

### Instance Cleanup
- Proper disposal of resources
- Unregistering event handlers
- Closing connections and files

### Scope Cleanup
- Proper disposal of scoped instances
- Cleanup after scope ends
- Memory leak prevention

## Advanced Patterns

### Factory Pattern with Lifetime
```
interface RepositoryFactory {
    createForContext(context)  // Creates appropriately scoped instance
}

class ContextualRepositoryFactory implements RepositoryFactory {
    createForContext(context) {
        if (context.type == "web_request") {
            return new ScopedTemplateRepository(context.requestId)
        } else {
            return new StatelessTemplateRepository()
        }
    }
}
```

### Prototype Pattern
```
container.registerPrototype(
    "template_processor",
    (config) => new TemplateProcessor(config)
)

// Usage
processor1 = container.create("template_processor", config1)
processor2 = container.create("template_processor", config2)
```

### Pool Pattern
```
interface ObjectPool<T> {
    acquire(): T
    release(obj: T)
}

class ConnectionPool implements ObjectPool<DatabaseConnection> {
    // Pool management implementation
}
```

## Best Practices

### Choose Appropriate Lifetime
- Singleton: Stateless, expensive to create, globally shared
- Transient: Stateful, request-scoped, simple objects
- Scoped: Request/session-scoped, stateful but shared within scope

### Consider Performance Implications
- Singleton: Best performance, but potential initialization delay
- Transient: Memory and performance cost of creation
- Scoped: Balance but with scope management overhead

### Plan for Testing
- Ensure lifetimes work appropriately in test scenarios
- Allow for different lifetimes in test environments
- Support for test-specific registrations

### Monitor Resource Usage
- Track instance counts
- Monitor memory usage patterns
- Identify potential memory leaks

### Document Lifetime Expectations
- Make lifetime behavior clear to consumers
- Document sharing implications
- Explain scope boundaries clearly

### Error Handling
- Handle creation failures appropriately
- Manage destruction failures
- Ensure proper cleanup on errors