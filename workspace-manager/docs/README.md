# DevMorph AI Studio - Workspace Manager Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Installation](#installation)
4. [Getting Started](#getting-started)
5. [Commands](#commands)
6. [Operational Modes](#operational-modes)
7. [Templates](#templates)
8. [Configuration](#configuration)
9. [Security](#security)
10. [Troubleshooting](#troubleshooting)
11. [Best Practices](#best-practices)
12. [Contributing](#contributing)

## Overview

The Workspace Manager is a comprehensive development environment management system for DevMorph AI Studio. It provides tools to create, manage, and orchestrate isolated development environments with different configurations tailored to specific needs.

### Key Features

- **Template-based creation**: Create workspaces from predefined templates
- **Multiple operational modes**: Support for dev, prod, staging, test, design, and mix modes
- **Full lifecycle management**: Create, start, stop, list, and destroy workspaces
- **State management**: Track workspace status and configuration in `.devmorph-state` files
- **Cross-platform compatibility**: POSIX-compliant shell scripting for universal compatibility
- **Integrated logging**: Comprehensive logging with configurable log levels
- **Built-in validation**: Extensive validation for inputs, paths, and system dependencies
- **Security-focused design**: Path traversal protection and input sanitization

## Architecture

The Workspace Manager follows a modular architecture:

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
│   ├── config-manager.sh          # Configuration management
│   ├── mode-handler.sh            # Mode switching
│   ├── validator.sh               # Input validation
│   ├── logger.sh                  # Logging system
│   └── helpers.sh                 # Utility functions
├── modes/                         # Mode-specific configurations
│   ├── dev/                       # Development mode
│   ├── prod/                      # Production mode
│   ├── staging/                   # Staging mode
│   ├── test/                      # Test mode
│   ├── design/                    # Design mode
│   └── mix/                       # Mixed mode
├── utils/                         # Utility scripts
│   └── compatibility.sh            # System compatibility check
└── README.md                      # This documentation
```

## Installation

### Prerequisites

- **Docker**: Required for containerization (v18.09+)
- **Docker Compose**: Required for orchestration (v1.25+ or Docker Compose V2)
- **POSIX-compliant shell**: For script execution (sh, dash, bash)
- **Basic Unix tools**: grep, sed, awk, cut, tr, etc.

### Installing Dependencies

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER
# Logout and login again for group changes to take effect
```

#### macOS:
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Or use Homebrew:
brew install docker docker-compose
```

#### CentOS/RHEL/Fedora:
```bash
sudo yum install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
# Logout and login again for group changes to take effect
```

### Verifying Installation

```bash
docker --version
docker-compose --version
docker info  # Should show no errors
```

## Getting Started

### Basic Usage

1. **Create a workspace**:
   ```bash
   devmorph workspace create --name my-project --template default --mode dev
   ```

2. **Start the workspace**:
   ```bash
   devmorph workspace start my-project
   ```

3. **Stop the workspace**:
   ```bash
   devmorph workspace stop my-project
   ```

4. **List all workspaces**:
   ```bash
   devmorph workspace list
   ```

5. **Destroy a workspace**:
   ```bash
   devmorph workspace destroy my-project
   ```

### Working with Modes

Switch between different operational modes:

```bash
# Switch to production mode
devmorph workspace mode set my-project --mode prod

# Check current mode
devmorph workspace mode show my-project
```

## Commands

### workspace create

Create a new workspace from a template.

```bash
devmorph workspace create --name <workspace-name> --template <template-name> [--mode <mode>]
```

**Options**:
- `--name`: Name of the workspace to create (required)
- `--template`: Name of the template to use (required)
- `--mode`: Mode for the workspace (dev, prod, staging, test, design, mix) - default: dev
- `--help`: Display usage information

**Examples**:
```bash
# Create a development workspace
devmorph workspace create --name my-dev-project --template default

# Create a production workspace
devmorph workspace create --name prod-env --template default --mode prod

# Create a design workspace
devmorph workspace create --name design-workspace --template default --mode design
```

### workspace start

Start a workspace container.

```bash
devmorph workspace start <workspace-name>
```

**Arguments**:
- `workspace-name`: Name of the workspace to start (required)

**Examples**:
```bash
devmorph workspace start my-project
```

### workspace stop

Stop a running workspace.

```bash
devmorph workspace stop <workspace-name>
```

**Arguments**:
- `workspace-name`: Name of the workspace to stop (required)

**Examples**:
```bash
devmorph workspace stop my-project
```

### workspace list

List all workspaces in the current directory.

```bash
devmorph workspace list
```

**Examples**:
```bash
devmorph workspace list
```

### workspace destroy

Destroy a workspace and remove all associated files.

```bash
devmorph workspace destroy <workspace-name> [--force]
```

**Arguments**:
- `workspace-name`: Name of the workspace to destroy (required)
- `--force`: Force destruction without confirmation

**Examples**:
```bash
# With confirmation prompt
devmorph workspace destroy my-project

# Force destruction
devmorph workspace destroy my-project --force
```

### workspace mode set

Set a workspace to a different operational mode.

```bash
devmorph workspace mode set <workspace-name> --mode <mode>
```

**Arguments**:
- `workspace-name`: Name of the workspace (required)
- `--mode`: New mode for the workspace (required)

**Examples**:
```bash
devmorph workspace mode set my-project --mode prod
```

### workspace mode show

Show the current mode of a workspace.

```bash
devmorph workspace mode show <workspace-name>
```

**Arguments**:
- `workspace-name`: Name of the workspace (required)

**Examples**:
```bash
devmorph workspace mode show my-project
```

## Operational Modes

### Dev Mode

**Purpose**: Development environment with hot-reload and debugging capabilities

**Services**:
- Node.js development server
- PostgreSQL database
- Redis cache

**Features**:
- Debugging ports enabled
- Verbose logging
- Volume mounts for hot-reload
- Resource limits disabled for development flexibility

**Ports**:
- 3000: Application server
- 9229: Node.js debugger
- 5432: PostgreSQL database
- 6379: Redis cache

### Prod Mode

**Purpose**: Production environment optimized for performance and security

**Services**:
- Production Node.js server
- PostgreSQL database
- Redis cache

**Features**:
- Resource limits enforced
- Minimal logging
- Security hardening
- Non-root user execution
- Auto-restart policies

**Ports**:
- 80: Application server
- 5432: PostgreSQL database
- 6379: Redis cache

### Staging Mode

**Purpose**: Staging environment for preview deployments and final testing

**Services**:
- Staging Node.js server
- PostgreSQL database
- Redis cache

**Features**:
- Moderate logging
- Staging-specific configurations
- Similar to production but with more visibility

**Ports**:
- 80: Application server
- 5432: PostgreSQL database
- 6379: Redis cache

### Test Mode

**Purpose**: Isolated environment for automated testing

**Services**:
- Test runner
- Temporary PostgreSQL database
- Redis cache

**Features**:
- Ephemeral data (clean state for each run)
- Test-specific configurations
- Single-run execution
- Resource constraints

**Ports**:
- None (runs to completion)

### Design Mode

**Purpose**: Creative environment with design tools and asset management

**Services**:
- Design tools (GIMP/Draw.io via web interface)
- MinIO for asset storage
- Collaboration platform

**Features**:
- Asset management
- Collaboration tools
- Web-based interfaces
- Large storage volumes

**Ports**:
- 8080: Design tools interface
- 9000: MinIO S3-compatible API
- 9001: MinIO web console
- 3002: Collaboration platform

### Mix Mode

**Purpose**: Hybrid environment combining development and design tools

**Services**:
- Dev server
- Web-based design tools
- PostgreSQL database
- Redis cache
- MinIO for assets

**Features**:
- Full development stack with design capabilities
- Shared services between dev and design
- Asset management integration

**Ports**:
- 3000: Development server
- 8080: Design tools
- 5432: PostgreSQL database
- 6379: Redis cache
- 9000: MinIO S3-compatible API
- 9001: MinIO web console

## Templates

Templates provide the foundation for workspaces. They define the initial structure, files, and configurations.

### Template Structure

```
/templates/
└── default/
    ├── docker-compose.yml
    ├── src/
    │   └── index.js
    ├── package.json
    └── README.md
```

### Creating Custom Templates

1. Create a new directory in `/templates/`
2. Add your files and configurations
3. Include a `docker-compose.yml` for container definitions
4. Test the template with:
   ```bash
   devmorph workspace create --name test-template --template my-template
   ```

### Template Best Practices

- Use descriptive names with alphanumeric characters, hyphens, and underscores
- Include a comprehensive README.md
- Provide sensible defaults in configuration files
- Document any required environment variables
- Test templates thoroughly before distribution

## Configuration

### Workspace State File

Each workspace contains a `.devmorph-state` file with JSON-formatted metadata:

```json
{
  "name": "workspace-name",
  "template": "template-name",
  "mode": "current-mode",
  "created_at": "2023-01-01T00:00:00Z",
  "status": "created|configured|running|stopped"
}
```

### Global Configuration

Global configuration is stored in `$XDG_CONFIG_HOME/devmorph/config.json` or `$HOME/.config/devmorph/config.json`:

```json
{
  "default": {
    "template": "default",
    "mode": "dev"
  },
  "docker": {
    "timeout": 300,
    "prune_interval": 86400,
    "auto_build": true
  },
  "cli": {
    "color_output": true,
    "verbose": false
  }
}
```

### Environment Variables

- `DEVMORPH_LOG_LEVEL`: Set logging level (debug, info, warn, error)
- `DEVMORPH_DEBUG`: Enable debug mode (1 = enabled)
- `XDG_CONFIG_HOME`: Override default config directory location

## Security

The Workspace Manager implements several security measures to protect against common vulnerabilities.

### Path Traversal Protection

All file operations validate paths to prevent directory traversal attacks:

```bash
# This is prevented:
devmorph workspace create --name "../../../etc/passwd" --template default

# This is allowed:
devmorph workspace create --name "my-safe-project" --template default
```

### Input Validation

All user inputs are validated against strict patterns:

- Workspace names: Alphanumeric characters, hyphens, and underscores only
- Template names: Alphanumeric characters, hyphens, and underscores only
- Mode names: Must be one of the predefined modes
- Paths: Validated to prevent traversal patterns

### Command Injection Prevention

User inputs are properly escaped before being used in shell commands:

```bash
# Safe command construction:
docker-compose -f "$workspace_path/docker-compose.yml" up -d

# Instead of dangerous:
eval "docker-compose -f $workspace_path/docker-compose.yml up -d"
```

### File Permissions

Workspace directories are created with appropriate permissions to prevent unauthorized access.

### Docker Security

- Containers run with non-root users where possible
- Resource limits prevent resource exhaustion
- Security options like `no-new-privileges` are enabled
- Network policies restrict unnecessary connections

## Troubleshooting

### Common Issues

#### Docker Not Available
**Problem**: Docker daemon is not running or not installed
**Solution**: 
1. Ensure Docker is installed: `sudo apt-get install docker.io`
2. Start Docker service: `sudo systemctl start docker`
3. Enable Docker service: `sudo systemctl enable docker`
4. Add user to docker group: `sudo usermod -aG docker $USER`
5. Logout and login again

#### Workspace Won't Start
**Problem**: Workspace fails to start
**Solution**:
1. Check status: `devmorph workspace list`
2. View logs: Check `.devmorph/logs/` directory
3. Verify Docker containers: `docker ps -a`
4. Check configuration: Examine `.devmorph-state` file

#### Mode Switching Problems
**Problem**: Mode changes don't take effect
**Solution**:
1. Stop workspace: `devmorph workspace stop <name>`
2. Change mode: `devmorph workspace mode set <name> --mode <new-mode>`
3. Start workspace: `devmorph workspace start <name>`

#### Permission Errors
**Problem**: Insufficient permissions to perform operations
**Solution**:
1. Check directory permissions: `ls -la`
2. Verify Docker group membership: `groups`
3. Check file ownership: `stat filename`

### Logging

Enable detailed logging for troubleshooting:

```bash
# Enable debug logging
export DEVMORPH_LOG_LEVEL=debug
devmorph workspace create --name test --template default

# Enable debug mode
export DEVMORPH_DEBUG=1
devmorph workspace start test
```

Logs are stored in `.devmorph/logs/` directory within each workspace.

## Best Practices

### Workspace Management

1. **Descriptive Naming**: Use meaningful names for workspaces
   ```bash
   # Good
   devmorph workspace create --name frontend-refactor-q4 --template react
   
   # Bad
   devmorph workspace create --name temp1 --template react
   ```

2. **Regular Cleanup**: Destroy unused workspaces to free resources
   ```bash
   devmorph workspace list
   devmorph workspace destroy old-project
   ```

3. **Mode Matching**: Use appropriate modes for your current work
   ```bash
   # Development work
   devmorph workspace create --name feature-branch --template default --mode dev
   
   # Production deployment
   devmorph workspace create --name prod-deployment --template default --mode prod
   ```

### Template Design

1. **Version Control**: Keep templates in version control
2. **Documentation**: Include comprehensive README files
3. **Defaults**: Provide sensible defaults for all configurations
4. **Testing**: Thoroughly test templates before distribution

### Security

1. **Principle of Least Privilege**: Run containers with minimal required permissions
2. **Regular Updates**: Keep base images and dependencies updated
3. **Network Isolation**: Use Docker networks to isolate services
4. **Secrets Management**: Never store secrets in templates or configurations

### Performance

1. **Resource Limits**: Set appropriate CPU and memory limits
2. **Volume Mounts**: Use volumes judiciously to avoid performance issues
3. **Caching**: Leverage Docker layer caching for faster builds
4. **Health Checks**: Implement health checks for automatic recovery

## Contributing

### Reporting Issues

1. Check existing issues: https://github.com/devmorph/workspace-manager/issues
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (OS, Docker version, etc.)

### Feature Requests

1. Search existing feature requests
2. Create a new issue with:
   - Clear description of the feature
   - Use cases and benefits
   - Implementation suggestions (optional)

### Code Contributions

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add/update tests
5. Update documentation
6. Submit a pull request

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/devmorph/workspace-manager.git
   cd workspace-manager
   ```

2. Install development dependencies:
   ```bash
   # Install bats for testing
   sudo apt-get install bats  # Ubuntu/Debian
   brew install bats-core      # macOS
   ```

3. Run tests:
   ```bash
   ./run-tests.sh
   ```

### Testing Guidelines

1. Write unit tests for new functions
2. Add integration tests for new workflows
3. Ensure all tests pass before submitting PR
4. Follow existing test patterns and conventions

### Documentation Updates

1. Keep README.md up to date with changes
2. Document new commands and options
3. Update examples and use cases
4. Follow existing documentation style

---

*Last updated: July 03, 2025*