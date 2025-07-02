# Workspace Manager Module

This module provides comprehensive workspace management functionality for DevMorph AI Studio, including creation, lifecycle management, and mode switching with full Docker orchestration support.

## Overview

The Workspace Manager enables users to create and manage isolated development environments with different configurations based on their specific needs (development, production, testing, design, etc.). All operations are orchestrated through Docker and Docker Compose with support for multiple operational modes.

## Features

- **Template-based creation**: Create workspaces from predefined templates in the `/templates/` directory
- **Multiple operational modes**: Support for dev, prod, staging, test, design, and mix modes
- **Full lifecycle management**: Create, start, stop, list, and destroy workspaces
- **State management**: Track workspace status and configuration in `.devmorph-state` files
- **Cross-platform**: POSIX-compliant shell scripting for universal compatibility
- **Integrated logging**: Comprehensive logging with configurable log levels
- **Validation**: Built-in validation for inputs, paths, and system dependencies
- **Security**: Path traversal protection and input sanitization
- **Error Handling**: Comprehensive error handling with graceful fallbacks

## Commands

### Create a Workspace

```bash
devmorph workspace create --name <workspace-name> --template <template-name> [--mode <mode>]
```

- `--name`: Name of the workspace to create (required)
- `--template`: Name of the template to use from `/templates/` (required)
- `--mode`: Mode for the workspace (dev, prod, staging, test, design, mix) - default: dev
- `--help`: Display usage information

**Examples:**
```bash
# Create a dev workspace with default mode
devmorph workspace create --name my-project --template default

# Create a production workspace
devmorph workspace create --name prod-env --template default --mode prod

# Create a design workspace
devmorph workspace create --name design-workspace --template default --mode design
```

### Start a Workspace

```bash
devmorph workspace start <workspace-name>
```

- `workspace-name`: Name of the workspace to start (required)

**Examples:**
```bash
devmorph workspace start my-project
```

### Stop a Workspace

```bash
devmorph workspace stop <workspace-name>
```

- `workspace-name`: Name of the workspace to stop (required)

**Examples:**
```bash
devmorph workspace stop my-project
```

### List All Workspaces

```bash
devmorph workspace list
```

Displays all workspaces in the current directory with their mode, status, and creation date.

### Destroy a Workspace

```bash
devmorph workspace destroy <workspace-name> [--force]
```

- `workspace-name`: Name of the workspace to destroy (required)
- `--force`: Force destruction without confirmation prompt

**Examples:**
```bash
# With confirmation prompt
devmorph workspace destroy my-project

# Force destruction without prompt
devmorph workspace destroy my-project --force
```

### Manage Workspace Modes

Set a workspace to a different mode:
```bash
devmorph workspace mode set <workspace-name> --mode <mode>
```

Show the current mode of a workspace:
```bash
devmorph workspace mode show <workspace-name>
```

- `workspace-name`: Name of the workspace (required)
- `--mode`: New mode for the workspace (required for set command)

**Examples:**
```bash
# Switch workspace to production mode
devmorph workspace mode set my-project --mode prod

# Check current mode
devmorph workspace mode show my-project
```

## Operational Modes

### Dev Mode
- **Purpose**: Development environment with hot-reload and debugging capabilities
- **Services**: Node.js development server, PostgreSQL database, Redis cache
- **Features**: Debugging ports enabled, verbose logging, volume mounts for hot-reload
- **Ports**: 3000 (app), 9229 (debugger), 5432 (DB), 6379 (cache)

### Prod Mode
- **Purpose**: Production environment optimized for performance and security
- **Services**: Production Node.js server, PostgreSQL database, Redis cache
- **Features**: Resource limits, minimal logging, security best practices
- **Ports**: 80 (app), 5432 (DB), 6379 (cache)

### Staging Mode
- **Purpose**: Staging environment for preview deployments and final testing
- **Services**: Staging Node.js server, PostgreSQL database, Redis cache
- **Features**: Moderate logging, staging-specific configurations
- **Ports**: 80 (app), 5432 (DB), 6379 (cache)

### Test Mode
- **Purpose**: Isolated environment for automated testing
- **Services**: Test runner, temporary PostgreSQL database, Redis cache
- **Features**: Ephemeral data, test-specific configurations, single-run execution
- **Ports**: None by default (runs to completion)

### Design Mode
- **Purpose**: Creative environment with design tools and asset management
- **Services**: Design tools (GIMP/Draw.io), MinIO for asset storage, collaboration platform
- **Features**: Asset management, collaboration tools, web-based interfaces
- **Ports**: 8080 (design tools), 9000/9001 (MinIO), 3002 (collaboration)

### Mix Mode
- **Purpose**: Hybrid environment combining development and design tools
- **Services**: Dev server, web-based design tools, PostgreSQL, Redis, MinIO
- **Features**: Full development stack with design capabilities
- **Ports**: 3000 (dev), 8080 (design), 5432 (DB), 6379 (cache), 9000/9001 (assets)

## Configuration and State Management

### State File
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
Global configuration is stored in `$XDG_CONFIG_HOME/devmorph/config.json` or `$HOME/.config/devmorph/config.json`.

## Dependencies

- **Docker**: Required for containerization
- **Docker Compose**: Required for orchestration (v1 or v2)
- **POSIX-compliant shell**: For script execution
- **Basic Unix tools**: grep, sed, awk, etc.

## Security and Validation

The Workspace Manager includes comprehensive security and validation layers:
- **Path Traversal Protection**: All file paths are validated to prevent directory traversal attacks
- **Input Validation**: All user inputs are validated against expected formats and ranges
- **Command Injection Prevention**: User inputs are properly escaped before use in shell commands
- **Directory Permissions**: Workspace directories are created with appropriate permissions
- **File Integrity**: Config and state files are updated atomically to prevent corruption

## Error Handling

The Workspace Manager includes graceful error handling:
- **Input validation for workspace names, template names, and modes**
- **System compatibility checks**
- **Docker/Docker Compose availability verification**
- **Workspace existence validation with path traversal protection**
- **Status validation (prevents starting already-running workspaces)**
- **Atomic file operations to prevent corruption**
- **Graceful error recovery with informative messages**
- **Detailed logging for debugging**

## Architecture

```
/workspace-manager/
├── devmorph (main CLI entry point)
├── workspace-create.sh      # Create new workspaces
├── workspace-start.sh       # Start workspace containers
├── workspace-stop.sh        # Stop workspace containers
├── workspace-destroy.sh     # Destroy workspaces
├── workspace-list.sh        # List all workspaces
├── workspace-mode.sh        # Manage workspace modes
├── lib/                     # Core libraries
│   ├── template-renderer.sh # Template processing
│   ├── docker-manager.sh    # Docker orchestration
│   ├── config-manager.sh    # Configuration management
│   ├── mode-handler.sh      # Mode switching
│   ├── validator.sh         # Input validation
│   ├── logger.sh            # Logging system
│   └── helpers.sh           # Utility functions
├── modes/                   # Mode-specific configurations
│   ├── dev/                 # Development mode
│   ├── prod/                # Production mode
│   ├── staging/             # Staging mode
│   ├── test/                # Test mode
│   ├── design/              # Design mode
│   └── mix/                 # Mixed mode
├── utils/                   # Utility scripts
│   └── compatibility.sh     # System compatibility check
└── README.md                # This documentation
```

## Best Practices

1. **Workspace Naming**: Use descriptive names with alphanumeric characters, hyphens, and underscores only
2. **Template Management**: Store custom templates in the `/templates/` directory
3. **Mode Selection**: Choose the appropriate mode for your current development phase
4. **Resource Management**: Use `devmorph workspace destroy` to free up system resources when no longer needed
5. **State Management**: The system automatically tracks workspace states, but you can inspect `.devmorph-state` files for debugging
6. **Security**: Never use relative paths or user input directly in file operations

## Troubleshooting

### Common Issues

**Docker Not Available**
- Ensure Docker is installed and running
- Check if Docker daemon has proper permissions

**Workspace Won't Start**
- Verify the workspace exists: `devmorph workspace list`
- Check the `.devmorph-state` file for status information
- Ensure sufficient system resources (memory, disk space)

**Mode Switching Problems**
- Modes can be changed even when workspace is running, but changes take effect on next start
- Make sure the requested mode exists in the `/workspace-manager/modes/` directory

**Permission Errors**
- Ensure proper ownership of workspace directories
- Check Docker group membership

### Logging
- Set `DEVMORPH_LOG_LEVEL=debug` for detailed logging
- Check `.devmorph/logs/` directory for persistent logs
- Use `DEVMORPH_DEBUG=1` for additional debug information

For additional support, check the logs and ensure all system dependencies are properly installed.