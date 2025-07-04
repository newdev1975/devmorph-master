# AI Assistant Development Guide

## Overview

This guide provides information for developers who want to extend or modify the AI Assistant module.

## Architecture Overview

The AI Assistant follows a modular, POSIX-compliant shell script architecture designed for cross-platform compatibility and maintainability.

### Module Structure

```
ai-assistant/
├── ai-code.sh          # Code assistance CLI command
├── ai-design.sh        # Design generation CLI command
├── ai-analyze.sh       # Analysis CLI command
├── ai-suggest.sh       # Suggestion CLI command
├── ai-chat.sh          # Chat CLI command
├── local-ai.sh         # Local AI model integration
├── cloud-ai.sh         # Cloud AI model integration
├── ai-model-manager.sh # Docker model management
├── model-health-check.sh # Model health and management
├── config/             # Configuration files
├── docs/               # Documentation
├── lib/                # Shared libraries
│   ├── context-manager.sh
│   ├── session-manager.sh
│   ├── hardware-detector.sh
│   └── model-selector.sh
└── tests/              # Test files
    ├── unit/
    ├── integration/
    └── performance/
```

## Adding New AI Models

To add support for a new AI model:

1. **Update Configuration**: Add model information to `config/ai-models.json`
2. **Update Docker Compose**: Add service definition to `docker-compose.yml` (for local models)
3. **Extend Model Selector**: Update `lib/model-selector.sh` to recognize the new model
4. **Add API Functions**: Create functions in `local-ai.sh` or `cloud-ai.sh` for the new model
5. **Update Health Checks**: Add health check logic to `model-health-check.sh`
6. **Write Tests**: Create appropriate unit and integration tests
7. **Update Documentation**: Document the new model in relevant guides

## Contributing Guidelines

### Code Standards

- Use POSIX-compliant shell scripting (no bashisms)
- Follow Google Shell Style Guide conventions
- Use 2-space indentation
- Keep functions focused with single responsibilities
- Use descriptive variable and function names
- Include function documentation with comments

### Testing Requirements

- All new functionality must have unit tests
- Integration tests for CLI commands
- Performance tests for core functions
- Test both positive and negative cases
- Test error handling paths

### Documentation

- Update API reference for new functions
- Add user guides for new features
- Include examples in documentation
- Document configuration options

## Core Libraries

### Hardware Detection (`lib/hardware-detector.sh`)

This library detects system capabilities and hardware configuration. When extending:

- Add detection for new hardware types
- Maintain cross-platform compatibility
- Use standard system tools (lspci, nvidia-smi, etc.)
- Handle missing tools gracefully

### Model Selection (`lib/model-selector.sh`)

This library selects the optimal AI model. When extending:

- Consider hardware requirements for new models
- Balance local vs cloud model selection
- Account for API availability and costs
- Maintain fast decision-making

### Context Management (`lib/context-manager.sh`)

This library manages AI interaction context. When extending:

- Use proper JSON handling (preferably with jq)
- Maintain data integrity across sessions
- Support various file types and sizes
- Implement proper cleanup for temporary data

### Session Management (`lib/session-manager.sh`)

This library tracks AI sessions. When extending:

- Ensure thread-safe operations
- Handle concurrent access properly
- Implement proper session cleanup
- Track metrics accurately

## Best Practices

### Error Handling

- Always check command return codes
- Provide meaningful error messages
- Fail gracefully when possible
- Log errors appropriately

### Performance Optimization

- Minimize external command calls
- Cache expensive operations when appropriate
- Use efficient text processing tools
- Consider memory usage for large contexts

### Security Considerations

- Validate all user input
- Sanitize API keys and sensitive data
- Use secure temporary files
- Protect against command injection

## Testing Strategy

### Unit Tests

Located in `tests/unit/`, these test individual functions:

```bash
bats tests/unit/test_ai_models.bats
```

### Integration Tests

Located in `tests/integration/`, these test CLI commands and workflows:

```bash
bats tests/integration/test_cli_commands.bats
```

### Performance Tests

Located in `tests/performance/`, these validate response times:

```bash
bats tests/performance/test_model_performance.bats
```

## Debugging Tips

### Common Issues

1. **Path Issues**: Use absolute paths when needed, handle script location correctly
2. **Environment Variables**: Ensure required variables are set in test environments
3. **Docker Dependencies**: Verify Docker is running for local model tests
4. **JSON Parsing**: Use jq for complex JSON operations

### Debugging Commands

```bash
# Enable debug mode in a script
set -x  # Enable tracing
set -u  # Exit on undefined variables

# Check environment
env | grep AI
docker ps
docker logs <container-name>
```

## Release Process

1. **Update Version**: Update version information if applicable
2. **Run All Tests**: Ensure all tests pass
3. **Validate Cross-Platform**: Test on different POSIX systems
4. **Update Documentation**: Ensure docs match implementation
5. **Create Release Notes**: Document new features and fixes