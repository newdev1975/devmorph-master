# Boundaries

## Definition
Boundaries in Onion Architecture define the separation between different layers and their responsibilities. Each boundary enforces the dependency rules and ensures that inner layers remain independent of outer layers.

## Layer Boundaries

### Domain Layer Boundary
- **Purpose**: Contains pure business logic and domain concepts
- **Contents**: Entities, value objects, domain services, domain events, repository interfaces
- **Dependencies**: None (independent core)
- **Technology**: Pure domain models without infrastructure concerns
- **Boundary Rules**: 
  - Cannot depend on any other layer
  - Contains only business concepts and rules
  - Interfaces are defined here, implementations are outside

### Application Layer Boundary
- **Purpose**: Orchestrates business operations and coordinates between domain and infrastructure
- **Contents**: Use cases, command/query handlers, application services, DTOs
- **Dependencies**: Only Domain layer
- **Technology**: Business process orchestration
- **Boundary Rules**:
  - Can use Domain layer interfaces
  - Cannot access Infrastructure directly
  - Defines application-specific business rules

### Infrastructure Layer Boundary
- **Purpose**: Implements technical concerns and external system integrations
- **Contents**: Repository implementations, external service adapters, logging, caching
- **Dependencies**: Domain and Application layers (for interfaces)
- **Technology**: Technical implementations
- **Boundary Rules**:
  - Implements Domain interfaces
  - Can depend on Domain and Application layers
  - Cannot depend on Presentation layer

### Presentation Layer Boundary
- **Purpose**: Adapts external interfaces to application use cases
- **Contents**: API controllers, CLI commands, UI adapters
- **Dependencies**: Application layer
- **Technology**: Interface technologies
- **Boundary Rules**:
  - Uses Application layer interfaces
  - Cannot access Domain or Infrastructure directly
  - Translates external requests to application use cases

## Cross-Cutting Concerns Boundary
- **Purpose**: Handles concerns that apply to multiple layers
- **Contents**: Logging, security, caching, configuration
- **Dependencies**: Applied across layers as needed
- **Boundary Rules**:
  - Implemented using infrastructure components
  - Should not affect core business logic
  - Applied through decorators, aspects, or interceptors

## Module Boundaries
- **Purpose**: Separates different functional areas of the application
- **Contents**: Complete feature sets with their own domain, application, and infrastructure
- **Boundary Rules**:
  - Each module follows Onion Architecture internally
  - Communication between modules through defined interfaces
  - Modules should be independently deployable

## Plugin Boundaries
- **Purpose**: Allows for extensible functionality without modifying core code
- **Contents**: Plugin implementations, plugin interfaces, plugin lifecycle management
- **Boundary Rules**:
  - Plugins implement defined interfaces
  - Core system doesn't depend on specific plugin implementations
  - Plugins can access core functionality through defined APIs

## Integration Boundaries
- **Purpose**: Define how the system communicates with external systems
- **Contents**: External service APIs, database abstractions, message queues
- **Boundary Rules**:
  - External dependencies accessed through adapters
  - Domain layer unaware of external systems
  - Infrastructure layer implements the integration details

## Testing Boundaries
- **Purpose**: Enable effective testing of different components
- **Contents**: Mock implementations, test fixtures, test strategies per layer
- **Boundary Rules**:
  - Each layer can be tested independently
  - Dependencies can be mocked at interface boundaries
  - Integration tests validate layer cooperation

## Security Boundaries
- **Purpose**: Protect different parts of the application with appropriate security
- **Contents**: Authentication, authorization, data validation, audit trails
- **Boundary Rules**:
  - Security concerns applied consistently across layers
  - Sensitive business logic protected by security boundaries
  - Access control enforced at layer boundaries