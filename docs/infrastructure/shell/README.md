# Shell Abstraction Layer

This module provides a cross-platform shell abstraction layer that allows the application to perform shell operations consistently across different platforms and shell environments.

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
├── adapters/                      # Shell-specific adapters
├── operations/                    # Utility operations
├── detection/                     # Feature detection
├── exceptions/                    # Shell-specific exceptions
├── implementations/               # Concrete implementations
└── ShellFactory.interface         # Factory for shell detection
```

## Features

- Cross-platform compatibility
- Consistent error handling
- Feature detection and compatibility checking
- Adapter-based design for different shell types
- Extensible architecture for new shell support