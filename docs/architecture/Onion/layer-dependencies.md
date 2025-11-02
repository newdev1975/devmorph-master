# Layer Dependencies

## Core Principle
In Onion Architecture, dependencies flow inward only. This means that outer layers depend on inner layers, but inner layers are independent of outer layers. This ensures that the core business logic remains isolated from technical implementation details.

## Dependency Rules

### ✅ Inner Layers Can Depend On:
- Themselves
- Other inner layers (toward the center)
- Interfaces defined within their layer or inner layers

### ❌ Outer Layers Cannot Depend On:
- Inner layers directly (must use dependency inversion)
- Concrete implementations in inner layers
- Business logic in inner layers

## Layer Structure

```
CORE (Innermost Layer)
├── Domain Layer          # Business rules, entities (core business logic)
├── Application Layer     # Use cases, workflows (application-specific business rules)
├── Infrastructure Layer  # Technical implementations (persistence, messaging, etc.)
└── Presentation Layer    # Interface adapters (minimal technical code)

EXTERNAL (Outermost Layer)  
├── UI/Presentation       # User interfaces
├── External Services     # APIs, databases
└── Frameworks/Tools      # Libraries, platforms
```

## Dependency Flow

### Presentation → Application
- Presentation layer depends on Application layer interfaces
- Uses application services to perform operations
- Does not know about infrastructure implementation details

### Application → Domain  
- Application layer depends on Domain layer interfaces
- Contains use cases that orchestrate domain objects
- Does not depend on infrastructure implementations

### Domain ← Infrastructure (via Dependency Inversion)
- Infrastructure implements Domain interfaces
- Domain does not depend on infrastructure details
- Dependency inversion principle is applied

## Dependency Injection Pattern
- Interfaces are defined in inner layers
- Implementations are in outer layers
- DI container resolves dependencies at runtime
- Runtime configuration determines which implementations to use

## Examples

### Correct Dependencies:
- Application services can use Domain interfaces
- Infrastructure implementations can implement Domain interfaces
- Presentation can use Application interfaces

### Incorrect Dependencies:
- Domain layer using Infrastructure implementations directly
- Application layer depending on Presentation layer
- Infrastructure layer depending on Presentation layer

## Benefits of Proper Dependencies
- Business logic is protected from technical changes
- Easier testing with mock implementations
- Flexibility to change implementations without affecting business logic
- Clear separation of concerns
- Improved maintainability and testability