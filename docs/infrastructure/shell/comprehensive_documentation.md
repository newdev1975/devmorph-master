# Shell Abstraction Layer - Complete Documentation

## Overview

The Shell Abstraction Layer is a cross-platform shell operations framework designed to provide consistent interfaces across different shell environments (POSIX, bash, zsh, PowerShell, dash) and operating systems (Linux, macOS, Windows).

## Architecture

The module follows the Onion Architecture pattern with clear separation of concerns:

### 1. Core Interfaces
- **ShellAbstraction**: Main interface for all shell operations
- **ShellAdapter**: Base interface for different shell adapters
- **Operation Interfaces**: File, String, Process, System operations
- **Detection Interfaces**: Shell and feature detection
- **Exception Interfaces**: Error handling contracts

### 2. Infrastructure Layer
- **Adapters**: POSIX, Bash, Zsh, PowerShell, Dash implementations
- **Operation Implementations**: Cross-platform operation handlers
- **Detection Systems**: Shell and feature detection
- **Compatibility Management**: Platform compatibility checking

## Features

### File Operations
- `mkdir(path)`: Create directories
- `rm(path)`: Remove files/directories
- `cp(src, dest)`: Copy files/directories
- `mv(src, dest)`: Move files/directories
- Path existence and type checking

### String Operations
- `trim(str)`: Remove leading/trailing whitespace
- `contains(haystack, needle)`: Check substring existence
- `replace(str, search, replace)`: String replacement
- Case conversion and string utilities

### Process Operations
- `execute(command)`: Execute commands safely
- `get_pid()`: Get current process ID
- `kill_process(pid)`: Terminate processes
- Process monitoring and management

### System Operations
- `get_os_type()`: Detect operating system
- `get_shell_type()`: Identify shell environment
- `check_command(cmd)`: Verify command availability
- Environment variable management

## Platform Support

### POSIX Compliance
- Full POSIX sh compatibility as baseline
- Strict adherence to POSIX standards
- Fallback mechanisms for complex operations

### Shell-Specific Features
- **Bash**: Advanced features, associative arrays, process substitution
- **Zsh**: macOS compatibility, extended features
- **PowerShell**: Native Windows integration
- **Dash**: Lightweight POSIX compliance
- **Default POSIX**: Universal compatibility

## Usage Examples

### Basic File Operations
```sh
# Create directory
posix_mkdir "/tmp/mydir"

# Copy file
posix_cp "/path/to/source.txt" "/path/to/dest.txt"

# Check if file exists
if posix_exists "/path/to/file.txt"; then
    echo "File exists"
fi
```

### String Operations
```sh
# Trim whitespace
trimmed=$(posix_trim "  hello world  ")

# Replace text
result=$(posix_replace "hello world" "world" "universe")

# Check substring
if posix_contains "hello world" "world"; then
    echo "Contains substring"
fi
```

### Cross-Platform Process Execution
```sh
# Execute command safely
if shell_abstraction_execute echo "Hello World"; then
    echo "Command executed successfully"
fi

# Get current process ID
current_pid=$(shell_abstraction_get_pid)
```

## Error Handling

The module provides consistent error handling across platforms:
- All functions return appropriate exit codes
- Error messages are logged to stderr
- Fallback mechanisms for unavailable features
- Graceful degradation for unsupported operations

## Testing Strategy

### Unit Tests
- Individual function testing with BATS framework
- Edge case handling verification
- Error condition testing
- Cross-platform behavior validation

### Integration Tests
- Complete workflow validation
- Adapter compatibility checking
- Cross-platform path handling
- Real-world usage scenarios

## Implementation Details

### Directory Structure
```
src/
├── infrastructure/
│   └── adapters/
│       └── shell/
│           ├── ShellAbstraction.interface      # Main interface
│           ├── ShellFactory.interface          # Factory pattern
│           ├── adapters/                       # Shell adapters
│           ├── operations/                     # Operation interfaces
│           ├── detection/                      # Detection interfaces
│           ├── exceptions/                     # Error interfaces
│           └── implementations/                # Concrete implementations
└── core/
    └── infrastructure/                         # Core interfaces
```

### Interface-Based Design
All components follow interface-based design for loose coupling:
- Easy testing and mocking
- Pluggable implementations
- Clear contracts between components
- Extensible architecture

## Cross-Platform Considerations

### Path Handling
- Automatic path separator normalization
- Windows/Unix path format conversion
- WSL (Windows Subsystem for Linux) support

### Command Availability
- Dynamic command detection
- Fallback mechanisms for unavailable commands
- Shell-specific command variants

### Operating System Detection
- Accurate platform identification
- Environment-specific behavior
- Feature availability checking

## Best Practices Implemented

1. **POSIX Compliance**: All code maintains POSIX sh compatibility
2. **Error Handling**: Consistent error reporting and handling
3. **Security**: Proper input validation and sanitization
4. **Performance**: Efficient resource usage
5. **Maintainability**: Clear, well-documented code
6. **Testability**: Comprehensive test coverage

## Future Extensions

The architecture supports easy extension for additional features:
- New shell type support
- Additional operation types
- Enhanced detection capabilities
- Advanced cross-platform utilities

This shell abstraction layer provides a robust, testable, and maintainable foundation for cross-platform shell operations in the DevMorph SRP Master project.