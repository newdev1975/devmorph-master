# DevMorph

A modern, enterprise-grade Bash framework built with Clean Architecture principles.

## 🎯 Project Goals

Build a maintainable, testable, and scalable framework for shell scripting that follows:
- **Clean Architecture** (Onion/Hexagonal)
- **Domain-Driven Design** (DDD)
- **SOLID Principles** (especially Single Responsibility Principle)
- **Test-Driven Development** (TDD)
- **True Cross-Platform** (Bash, Zsh, PowerShell support)

## 🏗️ Architecture

### Core Design Patterns
- **Onion Architecture** - Dependency inversion, layers point inward
- **DDD** - Domain-centric design with aggregates, entities, value objects
- **Dependency Injection** - Loose coupling, testability
- **Event Sourcing** - Event-driven architecture, audit trail
- **Adapter Pattern** - Platform abstraction (Bash/Zsh/PowerShell)
- **Repository Pattern** - Data access abstraction
- **Factory Pattern** - Object creation abstraction
- **Saga Pattern** - Distributed transaction management

### Layer Structure
```
┌─────────────────────────────────────┐
│      Infrastructure Layer           │
│  (Shell Abstraction, Adapters)     │
├─────────────────────────────────────┤
│       Application Layer             │
│   (Use Cases, DI Container)         │
├─────────────────────────────────────┤
│         Domain Layer                │
│  (Entities, Events, Aggregates)     │
└─────────────────────────────────────┘
```

## 🐚 Cross-Platform Support

Full native support for:
- **Linux**: Bash 4+, Dash, Zsh
- **macOS**: Bash, Zsh
- **Windows**: PowerShell 7+, Git Bash
- **WSL**: All Linux shells

## 📊 Current Status

🚧 **In Active Development** - Building foundation with TDD approach

### Implementation Progress
- [ ] Shell Abstraction Layer (Foundation)
- [ ] Dependency Injection Container
- [ ] Domain Layer (DDD)
- [ ] Event Sourcing
- [ ] Repository Pattern
- [ ] Factory Pattern
- [ ] Saga Pattern

## 🧪 Testing

- **Framework**: BATS (Bash Automated Testing System)
- **Approach**: Test-Driven Development (TDD)
- **Coverage Target**: 80%+
- **Test Types**: Unit, Integration, Cross-platform

## 📚 Documentation

See `/docs` directory for:
- Architecture Decision Records (ADRs)
- Design documents
- API documentation
- Pattern implementations

## 🚀 Development Approach

1. **Shell Abstraction First** - True cross-platform foundation
2. **Tests First (TDD)** - Write tests before implementation
3. **Small Commits** - Atomic, focused commits
4. **Feature Branches** - One feature per branch
5. **Pattern Compliance** - All SOLID principles, especially SRP
6. **Clean Code** - Readable, maintainable, well-documented

## 📝 License

MIT

## 👤 Author

Robert Kulig ([@RobertKuligDev](https://github.com/newdev1975))

---

**Note**: This is a complete rewrite focused on production-ready code quality and enterprise design patterns.
