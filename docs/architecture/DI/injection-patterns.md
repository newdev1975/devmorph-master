# Injection Patterns

## Overview
Dependency Injection patterns define how dependencies are provided to objects. The choice of pattern affects testability, design, and maintainability of the codebase.

## Constructor Injection

### Definition
Dependencies are provided through the constructor when an object is created.

### Advantages
- Dependencies are required and available when object is created
- Makes dependencies explicit and visible
- Ensures object is always in a valid state
- Easy to test with mock dependencies

### Pattern
```
class CreateTemplateHandler {
    TemplateRepository repository
    EventDispatcher dispatcher
    
    constructor(TemplateRepository repository, EventDispatcher dispatcher) {
        this.repository = repository
        this.dispatcher = dispatcher
    }
    
    handle(command) {
        // Use dependencies here
        template = repository.findById(command.id)
        dispatcher.dispatch(new TemplateCreated(template.id))
        return template.id
    }
}
```

### When to Use
- When dependencies are required for the object to function
- For immutable dependencies
- When the dependency count is manageable (typically < 5-7)

## Property Injection (Setter Injection)

### Definition
Dependencies are provided through setter methods after object creation.

### Advantages
- Allows for optional dependencies
- Dependencies can be changed after object creation
- Good for circular dependencies (though this should be avoided)

### Pattern
```
class TemplateService {
    TemplateRenderer renderer = null
    
    setTemplateRenderer(TemplateRenderer renderer) {
        this.renderer = renderer
    }
    
    render(template, variables) {
        if (renderer == null) {
            throw new IllegalStateException("Renderer not set")
        }
        return renderer.render(template, variables)
    }
}
```

### When to Use
- For optional dependencies
- When dependency changes after object creation
- For cross-cutting concerns like logging

## Method Injection

### Definition
Dependencies are provided as parameters to specific methods.

### Advantages
- Dependencies are only provided when needed
- Good for context-specific operations
- Allows for different implementations per call

### Pattern
```
class TemplateProcessor {
    process(templateData, TemplateValidator validator) {
        validationResult = validator.validate(templateData)
        // Process based on validation
    }
}
```

### When to Use
- For context-specific dependencies
- When different implementations are needed for different calls
- For optional operations that don't require permanent dependencies

## Interface-Based Injection

### Definition
Dependencies are injected based on interfaces implemented by the receiving object.

### Pattern
```
interface Injectable {
    setDependency(interface, implementation)
}

class TemplateEngine implements Injectable {
    setDependency(interface, implementation) {
        if (interface == TemplateRenderer) {
            this.renderer = implementation
        } else if (interface == TemplateValidator) {
            this.validator = implementation
        }
    }
}
```

### When to Use
- When multiple dependencies of different types are needed
- For framework-level dependency injection

## Service Locator Pattern

### Definition
Object retrieves dependencies from a central service locator rather than having them injected.

### Pattern
```
class TemplateService {
    handle(templateId) {
        repository = ServiceLocator.get(TemplateRepository)
        template = repository.findById(templateId)
        // Process template
    }
}
```

### Important Note
This pattern violates the dependency inversion principle and makes testing harder. It should generally be avoided in favor of direct injection patterns.

## Container-Aided Injection

### Definition
Dependencies are resolved and injected by the DI container using configuration.

### Pattern
```
// Container configuration
container.register(TemplateRepository, () => new FileTemplateRepository())
container.register(TemplateService, () => new TemplateService(
    container.get(TemplateRepository),
    container.get(EventDispatcher)
))

// Usage
service = container.get(TemplateService)  // Dependencies automatically injected
```

### When to Use
- When using a DI container
- For complex dependency trees
- When dependencies should be configured externally

## Best Practices

### Prefer Constructor Injection
- Makes dependencies explicit
- Ensures object validity
- Easier to test

### Minimize Dependency Count
- Keep constructor parameters under 5-7 items
- Consider extracting complex dependencies into aggregate services
- Use composition to group related dependencies

### Use Interface-Based Dependencies
- Depend on abstractions, not concrete implementations
- Makes testing and substitution easier
- Follows dependency inversion principle

### Validate Dependencies
- Check for null dependencies if using property injection
- Ensure required dependencies are available
- Fail fast if dependencies are missing

### Consider Lifecycle
- Match dependency lifecycle to dependent object lifecycle
- Use appropriate lifecycle management (singleton, transient, scoped)
- Be aware of shared state between objects

### Document Dependencies
- Make dependencies clear in class interfaces
- Document optional vs required dependencies
- Consider using attributes or annotations to document injection points