# ADR 003: Adopted Design Patterns

## Status
Accepted

## Context
Application is a cross-platform project creation framework with:
- Standard Docker workflow
- Alternatives: Cloud, Remote Server, Local
- Support for developers (Dev mode) and designers (Design mode)
- Backup, environment detection (OS, GPU)
- Multi-device and multi-OS compatibility
- Game-changing modes: Dev, Design, Mix

## Decision
Adopt the following design patterns as architectural foundation:

- **Onion/Hexagonal Architecture** – isolate domain from infrastructure
- **Domain-Driven Design (DDD)** – model Dev, Design, Mix as bounded contexts
- **Dependency Injection (DI)** – enable swappable infrastructure (Docker, Cloud, Local)
- **Event Sourcing** – provide audit trail, backups, and collaborative history
- **Adapter Pattern** – abstract OS, shell, GPU, and environment differences
- **Repository Pattern** – unify access to project data and assets
- **Factory Pattern** – create environment instances (Docker, Cloud, Remote, Local)
- **Saga Pattern** – orchestrate complex workflows (deployments, backups, sync)
- **SOLID Principles (SRP emphasis)** – ensure maintainability and modularity

## Consequences

### Positive
- Clear separation of concerns
- Extensible for new environments/workflows
- Supports both developers and designers
- Testable and maintainable

### Negative
- Higher initial complexity
- Requires strict discipline
