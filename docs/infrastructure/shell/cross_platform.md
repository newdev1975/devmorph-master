# Cross-Platform Support

This module provides comprehensive cross-platform support for different operating systems and shell environments.

## Windows Support

The shell abstraction layer includes specific handling for Windows environments:

- PowerShell adapter for native Windows command execution
- Path normalization between Unix and Windows formats
- Windows-specific command execution where appropriate
- WSL (Windows Subsystem for Linux) compatibility

## Cross-Platform Path Handling

The system provides utilities for proper path handling across platforms:

- `normalize_path()` - Converts paths to appropriate format for the current platform
- `to_windows_path()` - Converts to Windows-style backslash separators
- `to_unix_path()` - Converts to Unix-style forward slash separators
- `get_path_separator()` - Returns appropriate separator for platform

## Platform Detection

The system can detect and adapt to different platforms:

- Linux
- macOS (Darwin)
- Windows (including Cygwin, MSYS, WSL)
- FreeBSD
- Other POSIX-compatible systems

## Adapter Compatibility

Each adapter is designed to work optimally on its target platform:
- POSIX adapter: Universal compatibility
- Bash adapter: Enhanced features for Bash environments
- Zsh adapter: Additional capabilities for Zsh
- PowerShell adapter: Native Windows integration
- Dash adapter: Lightweight POSIX compliance