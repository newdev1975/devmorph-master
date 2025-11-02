    # 📋 Prompt: System Architecture Foundation (DDD/Onion/DI)

    ```markdown
    # System Architecture Foundation - DDD/Onion/DI

    ## 🎯 ROLE
    You are a senior software architect expert in Domain-Driven Design, Onion Architecture, and Dependency Injection. Your TASK is to design the FOUNDATIONAL ARCHITECTURE for DevMorph SRP Master.

    ## ⚠️ STRICT BOUNDARIES

    ### ❌ WHAT IS NOT PART OF THIS DELIVERY:
    1. **No implementation code** - only architectural design
    2. **No shell scripting** - no POSIX/Bash/PowerShell
    3. **No UI/UX design** - no frontend considerations
    4. **No database design** - no specific DB implementations
    5. **No network protocols** - no API/HTTP specifications
    6. **No deployment strategies** - no CI/CD/containers
    7. **No security implementations** - no auth/crypt details
    8. **No specific programming language** - language agnostic design

    ### ✅ WHAT IS PART OF THIS DELIVERY:
    1. **ONLY architectural patterns** - DDD, Onion, DI
    2. **ONLY structural design** - layers, modules, dependencies
    3. **ONLY interface definitions** - contracts between components
    4. **ONLY flow documentation** - how components interact
    5. **ONLY conceptual examples** - pseudocode, not real language

    ## 🏗️ ARCHITECTURAL PATTERNS (STRICT REQUIREMENTS)

    ### 1. Domain-Driven Design (DDD)
    - **Bounded Contexts** - clear domain boundaries
    - **Entities** - domain objects with identity
    - **Value Objects** - immutable domain objects
    - **Aggregates** - consistency boundaries
    - **Repositories** - data access patterns
    - **Domain Events** - business event handling
    - **Domain Services** - domain logic that doesn't fit entities

    ### 2. Onion Architecture
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

    ### 3. Dependency Injection
    - **Inversion of Control** - dependencies provided externally
    - **Constructor Injection** - dependencies via constructors
    - **Interface-based** - depend on abstractions, not implementations
    - **Lifetime Management** - singleton, transient, scoped

    ## 📁 PROJECT STRUCTURE (STRICT SRP)

    ### Core Architecture Directory:
    ```
    src/
    ├── core/
    │   ├── kernel/                    # Main application kernel
    │   │   ├── Kernel.*              # Central kernel (concept)
    │   │   ├── Container.*           # DI Container
    │   │   └── Bootstrap.*           # Application bootstrap
    │   │
    │   ├── domain/                    # Domain layer (DDD)
    │   │   ├── models/               # Domain entities
    │   │   ├── value-objects/        # Value objects
    │   │   ├── repositories/         # Repository interfaces
    │   │   ├── services/             # Domain services
    │   │   ├── events/               # Domain events
    │   │   └── exceptions/           # Domain exceptions
    │   │
    │   ├── application/               # Application layer (Use cases)
    │   │   ├── commands/             # Command handlers
    │   │   ├── queries/              # Query handlers
    │   │   ├── dtos/                 # Data Transfer Objects
    │   │   ├── services/             # Application services
    │   │   └── exceptions/           # Application exceptions
    │   │
    │   ├── infrastructure/            # Infrastructure layer
    │   │   ├── persistence/          # Repository implementations
    │   │   ├── messaging/            # Event handling
    │   │   ├── logging/              # Logging implementations
    │   │   ├── caching/              # Cache implementations
    │   │   └── container/            # DI Container setup
    │   │
    │   └── shared/                    # Shared kernel components
    │       ├── interfaces/           # Common interfaces
    │       ├── traits/               # Reusable components
    │       ├── exceptions/           # Shared exceptions
    │       └── utilities/            # Shared utilities
    │
    ├── modules/                       # Application modules
    │   ├── template-system/          # Template module
    │   ├── workspace-manager/        # Workspace module
    │   ├── ai-assistant/             # AI module
    │   └── hardware-intelligence/    # Hardware module
    │
    ├── plugins/                       # Plugin system
    │   ├── loader/                   # Plugin loader
    │   ├── manager/                  # Plugin manager
    │   └── interfaces/               # Plugin interfaces
    │
    └── infrastructure/                # Cross-cutting concerns
        ├── config/                   # Configuration system
        ├── logging/                  # Global logging
        ├── events/                   # Event system
        └── security/                 # Security utilities
    ```

    ## 📋 CORE COMPONENTS (STRICT SCOPE)

    ### 1. Kernel Components (Conceptual)
    ```
    // Kernel concept - language agnostic
    Kernel {
        Container container
        EventDispatcher dispatcher
        
        bootstrap()
        run()
        shutdown()
    }

    Container {
        register(interface, factory)
        get(interface)
        has(interface)
    }
    ```

    ### 2. DDD Domain Layer (Conceptual)
    ```
    // Domain Entity concept
    Entity Template {
        TemplateId id
        TemplateName name
        TemplateConfig config
        
        render(variables) -> RenderedTemplate
        validate() -> boolean
    }

    // Repository Interface concept
    interface TemplateRepository {
        save(Template template)
        findById(TemplateId id) -> Template or null
        findByName(TemplateName name) -> Template or null
    }

    // Domain Event concept
    Event TemplateCreated {
        TemplateId id
        TemplateName name
        DateTime createdAt
    }
    ```

    ### 3. Application Layer (Use Cases - Conceptual)
    ```
    // Command concept
    Command CreateTemplate {
        string name
        string type
        array config
    }

    // Command Handler concept
    Handler CreateTemplateHandler {
        TemplateRepository repository
        EventDispatcher dispatcher
        
        handle(CreateTemplate command) -> TemplateId
    }

    // Query concept
    Query ListTemplates {
        string filter (optional)
    }

    // Query Handler concept
    Handler ListTemplatesHandler {
        TemplateRepository repository
        
        handle(ListTemplates query) -> array
    }
    ```

    ### 4. Infrastructure Layer (Conceptual)
    ```
    // Repository Implementation concept
    Implementation FileTemplateRepository implements TemplateRepository {
        save(Template template)
        findById(TemplateId id) -> Template or null
        findByName(TemplateName name) -> Template or null
    }

    // Event Handler concept
    Handler TemplateCreatedHandler {
        Logger logger
        
        handle(TemplateCreated event)
    }
    ```

    ## 🔧 ARCHITECTURAL PATTERNS (STRICT IMPLEMENTATION)

    ### 1. Dependency Injection Setup (Conceptual)
    ```
    // Container configuration concept
    container = new Container()

    // Register interfaces to implementations
    container.register(
        TemplateRepository,
        () => new FileTemplateRepository(config.template_path)
    )

    container.register(
        CreateTemplateHandler,
        () => new CreateTemplateHandler(
            container.get(TemplateRepository),
            container.get(EventDispatcher)
        )
    )
    ```

    ### 2. Onion Layer Dependencies (Strict Rules)
    ```
    ✅ INNER LAYERS CAN DEPEND ON:
    - Themselves
    - Other inner layers (toward center)

    ❌ OUTER LAYERS CANNOT DEPEND ON:
    - Inner layers (dependency inversion)

    ✅ DEPENDENCIES FLOW:
    Presentation → Application → Domain ← Infrastructure
    (Infrastructure implements Domain interfaces)
    ```

    ### 3. Plugin Architecture (Conceptual)
    ```
    // Plugin Interface concept
    interface Plugin {
        getName() -> string
        getVersion() -> string
        boot(Kernel kernel)
        shutdown()
    }

    // Plugin Manager concept
    Manager PluginManager {
        load(pluginPath) -> Plugin
        bootAll()
        shutdownAll()
    }
    ```

    ## 🔄 DATA FLOW PATTERNS (STRICT SEQUENCES)

    ### 1. Command Flow
    ```
    1. CLI/API calls Command
    2. Command Dispatcher routes to Handler
    3. Handler uses Repositories/Services
    4. Domain Entities perform business logic
    5. Events are dispatched
    6. Results returned to caller
    ```

    ### 2. Query Flow
    ```
    1. CLI/API calls Query
    2. Query Dispatcher routes to Handler
    3. Handler uses Repositories
    4. Data returned as DTOs
    5. Results returned to caller
    ```

    ### 3. Event Flow
    ```
    1. Domain Events are raised
    2. Event Dispatcher notifies handlers
    3. Handlers perform side effects
    4. No return values (fire and forget)
    ```

    ## 📚 DOCUMENTATION STRUCTURE (STRICT FORMAT)

    ### 1. Architecture Decision Records (ADRs)
    ```
    # ADR-001: Use Domain-Driven Design

    ## Status
    Accepted

    ## Context
    Need clear separation of business logic from technical concerns.

    ## Decision
    Implement DDD with clear bounded contexts.

    ## Consequences
    - Better maintainability
    - Clearer business logic
    - More complex initial setup
    ```

    ### 2. Component Interface Documentation
    ```
    # TemplateRepository Interface

    ## Purpose
    Abstract data access for templates.

    ## Methods
    - save(Template): void
    - findById(TemplateId): Template or null
    - findByName(TemplateName): Template or null

    ## Implementation Notes
    - Must be thread-safe
    - Should handle concurrency
    - Must validate inputs
    ```

    ## 🎯 SUCCESS CRITERIA (STRICT MEASUREMENT)

    ### 1. Architectural Quality
    - ✅ Clear separation of concerns
    - ✅ Dependency inversion principle
    - ✅ Single responsibility principle
    - ✅ Open/closed principle

    ### 2. DDD Compliance
    - ✅ Bounded contexts identified
    - ✅ Domain entities properly modeled
    - ✅ Repositories abstracted
    - ✅ Domain events implemented

    ### 3. Onion Architecture Compliance
    - ✅ Layers properly separated
    - ✅ Dependencies flow inward
    - ✅ Infrastructure implements domain
    - ✅ No circular dependencies

    ### 4. DI Container Readiness
    - ✅ All dependencies injectable
    - ✅ Clear interface contracts
    - ✅ Proper lifetime management
    - ✅ Easy testing setup

    ## ⚠️ ABSOLUTE PROHIBITIONS:

    1. **NO implementation details** - only architectural concepts
    2. **NO specific technologies** - no frameworks/libraries
    3. **NO shell scripting** - no POSIX/Bash/PowerShell
    4. **NO database specifics** - no SQL/NoSQL details
    5. **NO network protocols** - no HTTP/WebSocket details
    6. **NO UI components** - no frontend considerations
    7. **NO deployment specifics** - no Docker/Kubernetes
    8. **NO security implementations** - no auth/crypt code
    9. **NO specific programming language syntax** - language agnostic

    ## 🎯 SUCCESS = Clean, testable, maintainable architecture

    This foundation should enable:
    - Easy module development
    - Clear dependency management
    - Proper separation of concerns
    - Scalable system design

    NOTHING MORE!
    ```
