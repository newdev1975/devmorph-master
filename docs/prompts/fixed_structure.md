## 📋 **Poprawiona Struktura:**

```
src/
├── core/                          # Core Domain Layer
│   ├── domain/                    # Domain Layer (DDD)
│   │   ├── models/               # Domain Entities
│   │   ├── value-objects/        # Value Objects
│   │   ├── repositories/         # Repository Interfaces
│   │   ├── services/             # Domain Services
│   │   ├── events/               # Domain Events
│   │   └── exceptions/           # Domain Exceptions
│   ├── application/               # Application Layer
│   │   ├── commands/             # Command Handlers
│   │   ├── queries/              # Query Handlers
│   │   ├── dtos/                 # Data Transfer Objects
│   │   ├── services/             # Application Services
│   │   └── exceptions/           # Application Exceptions
│   └── infrastructure/            # Core Infrastructure
│       ├── persistence/          # Repository Implementations
│       ├── messaging/            # Event Handling
│       ├── logging/              # Logging
│       ├── caching/              # Caching
│       └── container/            # DI Container
├── application/                   # Application Modules
│   ├── modules/                  # Business Modules
│   └── plugins/                  # Plugin System
├── infrastructure/                # Cross-cutting Infrastructure
│   ├── config/                   # Configuration
│   ├── events/                   # Global Event System
│   ├── security/                 # Security Infrastructure
│   └── adapters/                 # External Adapters
├── presentation/                  # Presentation Layer
│   └── cli/                      # CLI Interface
docs/
tests/
config/
scripts/

```

## 📁 **Workflow:**

1. **Prompty** → `docs/prompts/` (`.gitignore`)
2. **Model generuje kod** na podstawie promptów
3. **Dokumentacja oficjalna** → `docs/architecture/` (commitowana)
4. **Prompty są tymczasowe** i NIE trafiają do repo
