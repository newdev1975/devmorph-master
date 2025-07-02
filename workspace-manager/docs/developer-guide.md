# DevMorph AI Studio - Workspace Manager Developer Guide

## Table of Contents
1. [Development Environment](#development-environment)
2. [Project Structure](#project-structure)
3. [Code Standards](#code-standards)
4. [Library Development](#library-development)
5. [Testing](#testing)
6. [Documentation](#documentation)
7. [Release Process](#release-process)

## Development Environment

### Prerequisites

- **POSIX-compliant shell**: sh, dash, or bash
- **Git**: Version control system
- **Docker**: Containerization platform
- **Docker Compose**: Container orchestration
- **bats**: Bash Automated Testing System (for testing)
- **shellcheck**: Shell script linter
- **shfmt**: Shell script formatter

### Setting Up Development Environment

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose bats shellcheck
curl -L https://github.com/mvdan/sh/releases/download/v3.7.0/shfmt_v3.7.0_linux_amd64 -o shfmt
chmod +x shfmt
sudo mv shfmt /usr/local/bin/

# Install shellcheck from snap (recommended)
sudo snap install shellcheck
```

#### macOS:
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install docker docker-compose bats-core shellcheck shfmt
```

#### Fedora/CentOS/RHEL:
```bash
sudo dnf install docker docker-compose bats shellcheck
curl -L https://github.com/mvdan/sh/releases/download/v3.7.0/shfmt_v3.7.0_linux_amd64 -o shfmt
chmod +x shfmt
sudo mv shfmt /usr/local/bin/
```

### Verifying Installation

```bash
# Check all required tools
sh --version
docker --version
docker-compose --version
bats --version
shellcheck --version
shfmt --version
```

## Project Structure

The project follows a modular architecture with clear separation of concerns:

```
/workspace-manager/
├── devmorph                        # Main CLI entry point
├── workspace-create.sh            # Create new workspaces
├── workspace-start.sh             # Start workspace containers
├── workspace-stop.sh              # Stop workspace containers
├── workspace-destroy.sh           # Destroy workspaces
├── workspace-list.sh              # List all workspaces
├── workspace-mode.sh              # Manage workspace modes
├── lib/                           # Core libraries
│   ├── template-renderer.sh       # Template processing
│   ├── docker-manager.sh          # Docker orchestration
│   ├── config-manager.sh           # Configuration management
│   ├── mode-handler.sh            # Mode switching
│   ├── validator.sh               # Input validation
│   ├── logger.sh                  # Logging system
│   └── helpers.sh                 # Utility functions
├── modes/                         # Mode-specific configurations
│   ├── dev/
│   ├── prod/
│   ├── staging/
│   ├── test/
│   ├── design/
│   └── mix/
├── utils/                         # Utility scripts
│   └── compatibility.sh           # System compatibility check
├── docs/                          # Documentation
│   └── README.md                  # Developer guide
├── tests/                         # Test suite
│   ├── unit/
│   └── integration/
├── run-tests.sh                   # Test runner
└── README.md                      # User documentation
```

## Code Standards

### Shell Scripting Principles

1. **POSIX Compliance**: All scripts must be POSIX-compliant
2. **Error Handling**: Use `set -e` for immediate error exit
3. **Variable Quoting**: Always quote variables: `"$variable"`
4. **Exit Codes**: Use meaningful exit codes (0 = success, 1+ = error)
5. **Functions**: Use functions to encapsulate logic
6. **Comments**: Comment complex logic and public functions

### Naming Conventions

- **Variables**: Use `snake_case` for local variables
- **Functions**: Use `snake_case` for function names
- **Constants**: Use `UPPER_SNAKE_CASE` for constants
- **Files**: Use `kebab-case` for script files

### Example Function Template

```bash
#!/bin/sh
# Short description of what this function does
#
# Arguments:
# $1 - Description of first argument
# $2 - Description of second argument
#
# Returns:
# 0 on success, non-zero on error
# Sets output_variable with result

example_function() {
    # Validate inputs
    if [ -z "$1" ]; then
        echo "Error: First argument is required" >&2
        return 1
    fi
    
    # Local variables
    local input_param="$1"
    local result=""
    
    # Main logic
    result=$(echo "$input_param" | tr '[:upper:]' '[:lower:]')
    
    # Return result
    echo "$result"
    return 0
}
```

### Error Handling Patterns

```bash
# Immediate exit on error
set -e

# Function with error handling
safe_operation() {
    local result
    if ! result=$(some_command); then
        echo "Error: Failed to execute command" >&2
        return 1
    fi
    echo "$result"
    return 0
}

# Validate required parameters
validate_required_params() {
    if [ -z "$WORKSPACE_NAME" ] || [ -z "$TEMPLATE_NAME" ]; then
        echo "Error: Both workspace name and template name are required" >&2
        return 1
    fi
    return 0
}
```

### Security Best Practices

1. **Input Validation**: Always validate user inputs
2. **Path Sanitization**: Prevent path traversal attacks
3. **Command Injection**: Properly escape shell commands
4. **File Permissions**: Set appropriate file permissions
5. **Environment Variables**: Sanitize environment variable usage

## Library Development

### Creating New Libraries

1. **Location**: Place new libraries in `/workspace-manager/lib/`
2. **Naming**: Use descriptive names ending with `.sh`
3. **Header**: Include proper header comment with description
4. **Functions**: Export public functions, keep helpers private
5. **Dependencies**: Source required libraries at the top
6. **Documentation**: Document all public functions

### Library Template

```bash
#!/bin/sh
# Library Name Library for DevMorph AI Studio
# Provides functionality for [brief description]

# Exit on error
set -e

# Source required libraries
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"

# Only source if files exist
if [ -f "$LIB_DIR/helpers.sh" ]; then
    . "$LIB_DIR/helpers.sh"
fi

if [ -f "$LIB_DIR/logger.sh" ]; then
    . "$LIB_DIR/logger.sh"
fi

# Function to [brief description]
# Arguments:
# $1 - Description of first argument
# $2 - Description of second argument
# Returns:
# 0 on success, non-zero on error
# Outputs result to stdout
function_name() {
    local param1="$1"
    local param2="$2"
    
    # Validate inputs
    if [ -z "$param1" ]; then
        echo "Error: First parameter is required" >&2
        return 1
    fi
    
    # Main logic with error handling
    log_info "Executing function_name with param1: $param1"
    
    # Implementation here
    
    log_info "Function_name completed successfully"
    return 0
}
```

### Library Integration

When integrating libraries into scripts:

1. **Source Early**: Source libraries at the beginning of scripts
2. **Error Handling**: Handle missing library files gracefully
3. **Function Calls**: Call library functions with proper error checking
4. **Documentation**: Update script documentation for new dependencies

## Testing

### Test Framework

Tests use [bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System):

```
/tests/
├── unit/              # Unit tests for individual functions
│   ├── test_validator.bats
│   ├── test_helpers.bats
│   └── ...
└── integration/       # Integration tests for complete workflows
    ├── test_workspace_lifecycle.bats
    └── ...
```

### Writing Unit Tests

```bash
#!/usr/bin/env bats

# Unit tests for workspace-manager/lib/example.sh

setup() {
    load '../../workspace-manager/lib/example'
    load '../../workspace-manager/lib/logger'
    # Initialize logger if needed
    initialize_logger 2>/dev/null || true
}

@test "function_name - valid input" {
    run function_name "valid_input"
    [ "$status" -eq 0 ]
    [ "$output" = "expected_output" ]
}

@test "function_name - invalid input" {
    run function_name ""
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Error:" ]]
}

@test "function_name - edge cases" {
    run function_name "edge_case"
    [ "$status" -eq 0 ]
    # Additional assertions
}
```

### Running Tests

```bash
# Run all tests
./run-tests.sh

# Run specific test file
./run-tests.sh --test tests/unit/test_example.bats

# Run unit tests only
./run-tests.sh --unit

# Run integration tests only
./run-tests.sh --integration
```

### Test Coverage Goals

1. **Input Validation**: Test all boundary conditions and error cases
2. **Happy Path**: Test normal operation with valid inputs
3. **Error Conditions**: Test all possible error scenarios
4. **Edge Cases**: Test boundary conditions and special values
5. **Integration**: Test complete workflows end-to-end

### Continuous Integration

All changes must pass:

1. **Syntax Check**: `shellcheck` with no warnings
2. **Formatting**: `shfmt` with consistent formatting
3. **Unit Tests**: All unit tests must pass
4. **Integration Tests**: All integration tests must pass
5. **Code Review**: Manual code review by team members

## Documentation

### Updating Documentation

1. **User Docs**: Update `/workspace-manager/README.md` for user-facing changes
2. **Developer Docs**: Update `/workspace-manager/docs/README.md` for development changes
3. **Inline Comments**: Update function and variable comments
4. **Examples**: Update or add examples for new features

### Documentation Style

1. **Clear Language**: Use simple, clear English
2. **Consistent Formatting**: Follow existing documentation patterns
3. **Examples**: Include practical examples for all features
4. **Cross-references**: Link to related sections and concepts
5. **Version Information**: Include last updated dates

## Release Process

### Versioning

Follow [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Pre-release Checklist

1. **Code Freeze**: No new features in release branch
2. **Testing**: All tests pass on all supported platforms
3. **Documentation**: All documentation is up to date
4. **Changelog**: RELEASE_NOTES.md updated with changes
5. **Tagging**: Git tag created with version number
6. **Packaging**: Release packages built and verified

### Release Branch Strategy

```
main                    # Stable releases
├── v1.0.x              # Patch releases for v1.0
├── v1.1.x              # Patch releases for v1.1
└── develop             # Active development
    ├── feature/new-feature
    └── hotfix/critical-bug
```

### Release Steps

1. **Create Release Branch**:
   ```bash
   git checkout -b release/v1.2.0 develop
   ```

2. **Update Version Numbers**:
   - Update version in all relevant files
   - Update documentation references

3. **Final Testing**:
   ```bash
   ./run-tests.sh --all
   shellcheck *.sh */*.sh */*/*.sh
   ```

4. **Update Documentation**:
   - RELEASE_NOTES.md
   - README.md
   - Any other relevant docs

5. **Merge to Main**:
   ```bash
   git checkout main
   git merge release/v1.2.0
   git tag -a v1.2.0 -m "Release version 1.2.0"
   git push origin main --tags
   ```

6. **Merge Back to Develop**:
   ```bash
   git checkout develop
   git merge release/v1.2.0
   git push origin develop
   ```

7. **Clean Up**:
   ```bash
   git branch -d release/v1.2.0
   ```

### Post-release Activities

1. **Announcement**: Notify users of new release
2. **Monitor**: Watch for issues and feedback
3. **Support**: Respond to user questions
4. **Planning**: Begin planning next release

---

*Last updated: July 03, 2025*