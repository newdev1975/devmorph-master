# ADR 002: Shell Abstraction Layer as Foundation

## Status
Accepted

## Context
POSIX compliance requires abstraction over shell-specific operations.

## Decision
Implement Shell Abstraction Layer as FIRST component.

### Layer Responsibilities
1. **Detection**: Detect shell, platform, capabilities
2. **Abstraction**: Unified POSIX-compliant API
3. **Adaptation**: Shell-specific optimizations
4. **Isolation**: Other layers NEVER call shell commands directly

### POSIX Core + Shell Adapters
- **Core**: Pure POSIX sh implementation
- **BashAdapter**: Bash optimizations (when available)
- **ZshAdapter**: Zsh optimizations (when available)
- **PowerShellAdapter**: Windows native support

## Consequences

### Positive
- True cross-platform from day one
- Testable with dash (strictest shell)
- Performance optimizations without breaking compatibility
- Clear separation of concerns (SRP)

### Negative
- More initial work
- Requires multiple implementations
- Slight performance overhead

## Implementation Order
1. **Shell Abstraction** (POSIX baseline) ← START HERE
2. DI Container (uses Shell Abstraction)
3. Domain Layer (shell-agnostic)
4. Event Sourcing (uses Shell Abstraction for I/O)
5. Adapter, Repository, Factory, Saga patterns
