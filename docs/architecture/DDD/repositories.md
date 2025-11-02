# Repositories

## Definition
A Repository mediates between the domain and data mapping layers, acting like an in-memory collection of domain objects. It provides a querying capability while maintaining the illusion of a collection.

## Purpose
- Abstract persistence operations from domain logic
- Encapsulate data access patterns
- Provide collection-like interface to domain objects
- Separate domain model from infrastructure concerns

## Implementation Guidelines
1. Define repository interfaces in the domain layer
2. Implement repositories in the infrastructure layer
3. Repositories should only expose domain objects
4. Include only the necessary query methods
5. Follow the principle of dependency inversion

## Example Interface
```
interface TemplateRepository {
    save(Template template)
    findById(TemplateId id) -> Template or null
    findByName(TemplateName name) -> Template or null
    findAll() -> array<Template>
    delete(TemplateId id)
}
```

## Best Practices
- Keep interfaces focused on domain needs, not database capabilities
- Include only methods that are actually used by the domain
- Avoid exposing infrastructure-specific concepts in the interface
- Consider pagination for large result sets
- Separate read and write operations if needed (CQRS)

## Common Patterns
- Collection-like interface (add, remove, get)
- Query methods (find, search, filter)
- Persistence methods (save, update, delete)
- Batch operations when needed for performance