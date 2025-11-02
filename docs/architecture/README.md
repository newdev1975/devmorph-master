# Architecture Documentation

This documentation describes the foundational architecture of DevMorph SRP Master based on Domain-Driven Design (DDD), Onion Architecture, and Dependency Injection patterns.

## 🎯 Core Principles

The architecture follows three main principles:

1. **Domain-Driven Design (DDD)** - Business logic is organized around domain concepts
2. **Onion Architecture** - Layers with dependencies flowing inward
3. **Dependency Injection (DI)** - Inversion of control for managing dependencies

## 📁 Structure

The architecture is organized into the following layers:

```
CORE (Innermost Layer)
├── Domain Layer          # Business rules, entities
├── Application Layer     # Use cases, workflows
├── Infrastructure Layer  # Technical implementations
└── Presentation Layer    # Interface adapters (minimal)

EXTERNAL (Outermost Layer)  
├── UI/Presentation       # User interfaces
├── External Services     # APIs, databases
└── Frameworks/Tools      # Libraries, platforms
```

## 📋 Navigation

- [DDD Documentation](./DDD/) - Domain-Driven Design patterns and components
- [Onion Architecture](./Onion/) - Layer dependencies and boundaries
- [Dependency Injection](./DI/) - Container design and patterns
- [Architecture Decision Records](./ADRs/) - Key architectural decisions

## 🔄 Data Flows

- [Command Flow](./Onion/flow-diagrams.md#command-flow) - How commands are processed
- [Query Flow](./Onion/flow-diagrams.md#query-flow) - How queries are processed
- [Event Flow](./Onion/flow-diagrams.md#event-flow) - How events are handled