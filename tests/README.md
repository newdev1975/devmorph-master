# DevMorph AI Studio - Workspace Manager Tests

This directory contains unit and integration tests for the Workspace Manager module.

## Test Structure

```
tests/
├── unit/              # Unit tests for individual functions and libraries
│   ├── test_validator.bats      # Tests for validator library
│   ├── test_helpers.bats        # Tests for helpers library  
│   ├── test_logger.bats         # Tests for logger library
│   ├── test_mode_handler.bats   # Tests for mode handler library
│   ├── test_config_manager.bats # Tests for config manager library
│   └── test_docker_manager.bats # Tests for docker manager library
└── integration/       # Integration tests for complete workflows
    ├── test_workspace_lifecycle.bats  # Tests for workspace creation, start, stop, destroy
    └── test_cli.bats                    # Tests for CLI functionality
```

## Running Tests

### Prerequisites

Install bats (Bash Automated Testing System):
```bash
# On Ubuntu/Debian
sudo apt-get install bats

# On macOS with Homebrew
brew install bats-core

# Or install from source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

### Running All Tests

```bash
# Make the test runner executable
chmod +x run-tests.sh

# Run all tests
./run-tests.sh

# Run all tests with specific options
./run-tests.sh --all
```

### Running Specific Test Types

```bash
# Run only unit tests
./run-tests.sh --unit

# Run only integration tests  
./run-tests.sh --integration

# Run a specific test file
./run-tests.sh --test tests/unit/test_validator.bats
```

## Test Framework

Tests are written using [Bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System), which is POSIX-compliant and works well with shell scripts.

### Test Structure

Each test file follows this basic structure:

```bash
#!/usr/bin/env bats

# Load dependencies
load '../path/to/library'

@test "test description" {
    run function_to_test "parameters"
    [ "$status" -eq 0 ]          # Check exit status
    [ "$output" = "expected" ]   # Check output
}
```

### Test Guidelines

1. **Unit Tests**: Test individual functions in isolation
2. **Integration Tests**: Test complete workflows and interactions between components
3. **Mocking**: Where possible, avoid external dependencies like Docker in unit tests
4. **Cleanup**: Always clean up temporary files and directories
5. **Idempotency**: Tests should produce the same results when run multiple times

## Coverage

The test suite aims to cover:

- **Input validation**: All user inputs are properly validated
- **Error handling**: Proper error responses under various failure conditions
- **Security**: Path traversal protection and input sanitization
- **Functionality**: Core features work as expected
- **Integration**: Components work together correctly