# Domain Services

## Definition
A Domain Service represents domain logic that doesn't naturally fit within an Entity or Value Object. It contains operations that act on multiple domain objects or represents a domain concept that is not naturally a thing.

## Characteristics
- Contains domain logic that doesn't fit within entities or value objects
- Represents operations that involve multiple domain objects
- Stateless or has temporary state for single operations
- Expresses domain concepts that are not naturally objects

## When to Use Domain Services
- Operations that involve multiple entities or value objects
- Operations that require external services but are part of domain logic
- Complex domain algorithms that don't belong to a specific entity
- Operations that need to be exposed to other subsystems

## Implementation Guidelines
1. Keep services focused on domain logic, not infrastructure concerns
2. Name services to reflect domain concepts, not technical concepts
3. Use dependency injection for external dependencies
4. Ensure services follow single responsibility principle
5. Make services stateless where possible

## Example Structure
```
interface TemplateRenderingService {
    render(templateId, variables) -> RenderedTemplate
    validateTemplate(template) -> ValidationResult
}

class FileTemplateRenderingService implements TemplateRenderingService {
    TemplateRepository templateRepository
    TemplateEngine templateEngine
    
    render(templateId, variables) -> RenderedTemplate {
        template = templateRepository.findById(templateId)
        return templateEngine.render(template, variables)
    }
    
    validateTemplate(template) -> ValidationResult {
        // Domain-specific validation logic
        return templateEngine.validate(template)
    }
}
```

## Best Practices
- Keep services focused on a single domain capability
- Use interfaces to define service contracts
- Avoid anemic domain models by keeping business logic in entities when appropriate
- Consider using domain events to decouple complex operations
- Ensure services are testable with proper dependency injection