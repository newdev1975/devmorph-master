# Flow Diagrams

## Command Flow

The Command Flow handles operations that change the state of the system. It follows a pattern of receiving a command, processing it through the application layer, and executing domain logic.

```
1. CLI/API receives Command
   ↓
2. Command Dispatcher routes to Handler
   ↓
3. Application Handler uses Domain Services/Repositories
   ↓
4. Domain Entities perform business logic and validation
   ↓
5. Domain Events are raised
   ↓
6. Infrastructure handles persistence and side effects
   ↓
7. Results returned to caller
```

### Example:
```
Command: CreateTemplate {
    string name
    string type
    array config
}

Flow:
CLI → Command Dispatcher → CreateTemplateHandler → 
TemplateRepository → Template Entity → TemplateCreated Event → 
Persistence Infrastructure → Response to CLI
```

## Query Flow

The Query Flow handles read operations that retrieve data from the system without changing state. It typically bypasses domain validation since no modifications are made.

```
1. CLI/API receives Query
   ↓
2. Query Dispatcher routes to Handler
   ↓
3. Application Handler uses Domain Repository
   ↓
4. Infrastructure retrieves data from persistence
   ↓
5. Data returned as DTOs (Data Transfer Objects)
   ↓
6. Results returned to caller
```

### Example:
```
Query: ListTemplates {
    string filter (optional)
}

Flow:
CLI → Query Dispatcher → ListTemplatesHandler → 
TemplateRepository → Infrastructure Persistence → 
DTOs → Response to CLI
```

## Event Flow

The Event Flow handles asynchronous processing of domain events. These represent important occurrences that may trigger side effects or updates in other parts of the system.

```
1. Domain Entity raises Domain Event
   ↓
2. Event Dispatcher notifies registered handlers
   ↓
3. Multiple Event Handlers process the event
   ↓
4. Side effects executed (logging, notifications, etc.)
   ↓
5. No return values (fire and forget)
```

### Example:
```
Event: TemplateCreated {
    TemplateId id
    TemplateName name
    DateTime createdAt
}

Flow:
Template Entity → Event Dispatcher → 
[TemplateCreatedHandler, LoggingHandler, NotificationHandler] → 
Side effects (DB logging, email notification, cache update)
```

## Layer Interaction Flow

Shows how different layers interact in the Onion Architecture:

```
Presentation (CLI/HTTP) → Application Layer → Domain Layer ← Infrastructure Layer
                                    ↑                           ↓
                             (Uses interfaces)            (Implements interfaces)
```

## Dependency Injection Flow

The flow of dependency resolution in the system:

```
1. Container configuration registers interfaces to implementations
2. Runtime resolves dependencies when objects are created
3. Outer layers provide implementations for inner layer interfaces
4. Inner layers only depend on abstractions, not concrete implementations
```

## Plugin Loading Flow

For the plugin architecture:

```
1. Plugin Manager discovers available plugins
2. Plugins register their components with the DI container
3. Plugin interfaces are implemented with concrete plugin implementations
4. Application uses plugin components through registered interfaces
```