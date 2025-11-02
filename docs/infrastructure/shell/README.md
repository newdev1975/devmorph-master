# Shell Abstraction Layer

This module provides a comprehensive cross-platform shell abstraction layer that allows the application to perform shell operations consistently across different platforms and shell environments.

## Overview

The shell abstraction layer implements an adapter pattern to provide a consistent interface for shell operations regardless of the underlying shell environment. It supports:

- POSIX sh (baseline compatibility)
- Bash (extended features)
- Zsh (macOS compatibility)
- PowerShell (Windows compatibility)
- Dash (lightweight compatibility)

## Architecture

The module follows the Onion Architecture pattern with clear separation of concerns:

```
src/infrastructure/adapters/shell/
├── ShellAbstraction.interface     # Main abstraction interface
├── ShellFactory.interface         # Factory for shell detection
├── adapters/                      # Shell-specific adapters
├── operations/                    # Utility operations
├── detection/                     # Feature detection
├── exceptions/                    # Shell-specific exceptions
├── implementations/               # Concrete implementations
├── shell_utils.sh                 # Shared utilities
└── cross_platform_utils.sh        # Cross-platform utilities
```

## Features

- Cross-platform compatibility (Linux, macOS, Windows)
- Consistent error handling across all operations
- Feature detection and compatibility checking
- Adapter-based design for different shell types
- Full POSIX compliance with shell-specific extensions
- Comprehensive unit and integration testing
- Complete documentation and validation

## Supported Operations

### File Operations
- `mkdir`, `rm`, `cp`, `mv` with proper error handling
- Path existence and type checking
- File read/write operations

### String Operations  
- `trim`, `contains`, `replace`, case conversion
- String manipulation utilities
- Pattern matching functions

### Process Operations
- Command execution with proper exit code handling
- Process management (get PID, kill process, monitoring)
- Background execution support

### System Operations
- OS and shell type detection
- Command availability checking
- Environment variable management

## Testing

All functionality is covered by:
- 42 unit tests (BATS framework)
- 29 integration tests (BATS framework) 
- Complete cross-platform workflow validation

## Implementation Status

✓ All planned features implemented  
✓ All tests passing (71/71)  
✓ Cross-platform compatibility verified
✓ Complete documentation provided
✓ Validation script included