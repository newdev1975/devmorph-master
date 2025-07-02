# DevMorph AI Studio - Workspace Manager API Reference

## Table of Contents
1. [Overview](#overview)
2. [Core Libraries](#core-libraries)
3. [Public Functions](#public-functions)
4. [Data Structures](#data-structures)
5. [Environment Variables](#environment-variables)
6. [Error Codes](#error-codes)

## Overview

This document provides a technical reference for the Workspace Manager's public API. It details the available functions, data structures, and interfaces that can be used by developers extending or integrating with the system.

## Core Libraries

### template-renderer.sh
Provides functionality for processing templates and rendering files.

### docker-manager.sh
Manages Docker containers and orchestration.

### config-manager.sh
Handles configuration files and state management.

### mode-handler.sh
Manages operational modes and mode switching.

### validator.sh
Provides input validation and sanitization.

### logger.sh
Implements logging system with multiple levels.

### helpers.sh
Contains utility functions and common operations.

## Public Functions

### Template Renderer

#### render_template
Render a template file using environment variables.

```bash
render_template "$template_path" "$output_path"
```

**Parameters**:
- `$1` - Template file path
- `$2` - Output file path

**Returns**:
- 0 on success
- Non-zero on error

#### validate_workspace_name
Validate workspace name for security and format compliance.

```bash
validate_workspace_name "$name"
```

**Parameters**:
- `$1` - Workspace name to validate

**Returns**:
- 0 if valid
- Non-zero if invalid

#### workspace_exists
Check if a workspace with the given name already exists.

```bash
workspace_exists "$name"
```

**Parameters**:
- `$1` - Workspace name to check

**Returns**:
- 0 if exists
- Non-zero if doesn't exist

### Docker Manager

#### check_docker
Check if Docker is available and running.

```bash
check_docker
```

**Returns**:
- 0 if Docker is available
- Non-zero if Docker is unavailable

#### check_docker_compose
Check if Docker Compose is available.

```bash
check_docker_compose
```

**Returns**:
- 0 if Docker Compose is available
- Non-zero if Docker Compose is unavailable

#### start_workspace
Start a workspace using Docker Compose.

```bash
start_workspace "$workspace_path"
```

**Parameters**:
- `$1` - Path to workspace directory

**Returns**:
- 0 on success
- Non-zero on error

#### stop_workspace
Stop a workspace using Docker Compose.

```bash
stop_workspace "$workspace_path"
```

**Parameters**:
- `$1` - Path to workspace directory

**Returns**:
- 0 on success
- Non-zero on error

#### update_workspace_state
Update the workspace state in the state file.

```bash
update_workspace_state "$workspace_path" "$new_state"
```

**Parameters**:
- `$1` - Path to workspace directory
- `$2` - New state value

**Returns**:
- 0 on success
- Non-zero on error

#### is_workspace_running
Check if a workspace is currently running.

```bash
is_workspace_running "$workspace_path"
```

**Parameters**:
- `$1` - Path to workspace directory

**Returns**:
- 0 if running
- Non-zero if not running

### Config Manager

#### read_config_value
Read a value from a JSON configuration file.

```bash
read_config_value "$config_file" "$key"
```

**Parameters**:
- `$1` - Configuration file path
- `$2` - Key to read

**Returns**:
- 0 on success, outputs value to stdout
- Non-zero on error

#### write_config_value
Write a value to a JSON configuration file.

```bash
write_config_value "$config_file" "$key" "$value"
```

**Parameters**:
- `$1` - Configuration file path
- `$2` - Key to write
- `$3` - Value to write

**Returns**:
- 0 on success
- Non-zero on error

#### initialize_workspace_config
Initialize configuration for a new workspace.

```bash
initialize_workspace_config "$workspace_path" "$workspace_name" "$template_name" "$mode"
```

**Parameters**:
- `$1` - Workspace directory path
- `$2` - Workspace name
- `$3` - Template name
- `$4` - Mode

**Returns**:
- 0 on success
- Non-zero on error

#### update_workspace_config
Update a specific configuration value for a workspace.

```bash
update_workspace_config "$workspace_path" "$key" "$value"
```

**Parameters**:
- `$1` - Workspace directory path
- `$2` - Key to update
- `$3` - Value to set

**Returns**:
- 0 on success
- Non-zero on error

#### load_workspace_config
Load workspace configuration into environment variables.

```bash
load_workspace_config "$workspace_path"
```

**Parameters**:
- `$1` - Workspace directory path

**Returns**:
- 0 on success
- Non-zero on error

#### get_global_config_dir
Get the path to the global configuration directory.

```bash
get_global_config_dir
```

**Returns**:
- 0 on success, outputs directory path to stdout
- Non-zero on error

#### initialize_global_config
Initialize global configuration.

```bash
initialize_global_config
```

**Returns**:
- 0 on success
- Non-zero on error

### Mode Handler

#### get_available_modes
Get a list of available operational modes.

```bash
get_available_modes
```

**Returns**:
- 0 on success, outputs modes to stdout
- Non-zero on error

#### validate_mode
Validate if a mode is supported.

```bash
validate_mode "$mode"
```

**Parameters**:
- `$1` - Mode name to validate

**Returns**:
- 0 if valid
- Non-zero if invalid

#### get_mode_path
Get the path to a specific mode configuration.

```bash
get_mode_path "$mode"
```

**Parameters**:
- `$1` - Mode name

**Returns**:
- 0 on success, outputs path to stdout
- Non-zero on error

#### switch_workspace_mode
Switch a workspace to a different mode.

```bash
switch_workspace_mode "$workspace_path" "$new_mode"
```

**Parameters**:
- `$1` - Workspace directory path
- `$2` - New mode name

**Returns**:
- 0 on success
- Non-zero on error

#### get_workspace_mode
Get the current mode of a workspace.

```bash
get_workspace_mode "$workspace_path"
```

**Parameters**:
- `$1` - Workspace directory path

**Returns**:
- 0 on success, outputs mode to stdout
- Non-zero on error

#### get_workspace_mode_safe
Get the current mode of a workspace with error handling.

```bash
get_workspace_mode_safe "$workspace_path"
```

**Parameters**:
- `$1` - Workspace directory path

**Returns**:
- 0 on success, outputs mode to stdout
- Non-zero on error

### Validator

#### validate_workspace_name
Validate workspace name format and security.

```bash
validate_workspace_name "$name"
```

**Parameters**:
- `$1` - Workspace name to validate

**Returns**:
- 0 if valid
- Non-zero if invalid

#### validate_template_name
Validate template name format and security.

```bash
validate_template_name "$template"
```

**Parameters**:
- `$1` - Template name to validate

**Returns**:
- 0 if valid
- Non-zero if invalid

#### validate_path
Validate file path for security issues.

```bash
validate_path "$path"
```

**Parameters**:
- `$1` - Path to validate

**Returns**:
- 0 if valid
- Non-zero if invalid

#### validate_directory_exists
Check if a directory exists and is readable.

```bash
validate_directory_exists "$dir_path"
```

**Parameters**:
- `$1` - Directory path to check

**Returns**:
- 0 if exists and readable
- Non-zero if doesn't exist or not readable

#### validate_file_exists
Check if a file exists and is readable.

```bash
validate_file_exists "$file_path"
```

**Parameters**:
- `$1` - File path to check

**Returns**:
- 0 if exists and readable
- Non-zero if doesn't exist or not readable

#### validate_docker_compose_file
Validate Docker Compose file format and security.

```bash
validate_docker_compose_file "$compose_file"
```

**Parameters**:
- `$1` - Docker Compose file path

**Returns**:
- 0 if valid
- Non-zero if invalid

#### validate_mode
Validate mode name against available modes.

```bash
validate_mode "$mode"
```

**Parameters**:
- `$1` - Mode name to validate

**Returns**:
- 0 if valid
- Non-zero if invalid

#### validate_workspace_path
Validate workspace path to prevent directory traversal.

```bash
validate_workspace_path "$path"
```

**Parameters**:
- `$1` - Path to validate

**Returns**:
- 0 if valid
- Non-zero if invalid

### Logger

#### set_log_level
Set the current logging level.

```bash
set_log_level "$level"
```

**Parameters**:
- `$1` - Log level (debug, info, warn, error)

**Returns**:
- 0 on success
- Non-zero on error

#### log_message
Log a message at a specific level.

```bash
log_message "$level" "$message"
```

**Parameters**:
- `$1` - Log level (DEBUG, INFO, WARN, ERROR)
- `$2` - Message to log

**Returns**:
- 0 on success
- Non-zero on error

#### log_debug
Log a debug message.

```bash
log_debug "$message"
```

**Parameters**:
- `$1` - Message to log

**Returns**:
- 0 on success
- Non-zero on error

#### log_info
Log an info message.

```bash
log_info "$message"
```

**Parameters**:
- `$1` - Message to log

**Returns**:
- 0 on success
- Non-zero on error

#### log_warn
Log a warning message.

```bash
log_warn "$message"
```

**Parameters**:
- `$1` - Message to log

**Returns**:
- 0 on success
- Non-zero on error

#### log_error
Log an error message.

```bash
log_error "$message"
```

**Parameters**:
- `$1` - Message to log

**Returns**:
- 0 on success
- Non-zero on error

#### log_to_file
Log a message to a specific file.

```bash
log_to_file "$log_file" "$message"
```

**Parameters**:
- `$1` - Log file path
- `$2` - Message to log

**Returns**:
- 0 on success
- Non-zero on error

#### initialize_logger
Initialize the logging system.

```bash
initialize_logger
```

**Returns**:
- 0 on success
- Non-zero on error

#### get_current_log_level
Get the current logging level as a string.

```bash
get_current_log_level
```

**Returns**:
- 0 on success, outputs level to stdout
- Non-zero on error

### Helpers

#### command_exists
Check if a command exists in the system.

```bash
command_exists "$command"
```

**Parameters**:
- `$1` - Command name to check

**Returns**:
- 0 if command exists
- Non-zero if command doesn't exist

#### get_script_dir
Get the directory of the current script.

```bash
get_script_dir
```

**Returns**:
- 0 on success, outputs directory path to stdout
- Non-zero on error

#### create_temp_file
Create a temporary file with proper cleanup.

```bash
create_temp_file "$prefix"
```

**Parameters**:
- `$1` - Prefix for the temporary file

**Returns**:
- 0 on success, outputs file path to stdout
- Non-zero on error

#### cleanup_temp_files
Clean up temporary files.

```bash
cleanup_temp_files "$file1" "$file2" ...
```

**Parameters**:
- `$@` - List of files to delete

**Returns**:
- 0 on success
- Non-zero on error

#### is_linux
Check if running on Linux.

```bash
is_linux
```

**Returns**:
- 0 if running on Linux
- Non-zero if not running on Linux

#### is_macos
Check if running on macOS.

```bash
is_macos
```

**Returns**:
- 0 if running on macOS
- Non-zero if not running on macOS

#### is_windows
Check if running on Windows (WSL/Cygwin).

```bash
is_windows
```

**Returns**:
- 0 if running on Windows
- Non-zero if not running on Windows

#### get_os
Get the current operating system name.

```bash
get_os
```

**Returns**:
- 0 on success, outputs OS name to stdout
- Non-zero on error

#### is_docker_available
Check if Docker is available.

```bash
is_docker_available
```

**Returns**:
- 0 if Docker is available
- Non-zero if Docker is not available

#### is_docker_compose_available
Check if Docker Compose is available.

```bash
is_docker_compose_available
```

**Returns**:
- 0 if Docker Compose is available
- Non-zero if Docker Compose is not available

#### wait_for_port
Wait for a port to become available.

```bash
wait_for_port "$port" "$timeout"
```

**Parameters**:
- `$1` - Port number
- `$2` - Timeout in seconds (default: 30)

**Returns**:
- 0 if port becomes available
- Non-zero on timeout or error

#### to_lowercase
Convert string to lowercase.

```bash
to_lowercase "$string"
```

**Parameters**:
- `$1` - String to convert

**Returns**:
- 0 on success, outputs converted string to stdout
- Non-zero on error

#### file_contains_string
Check if a file contains a specific string.

```bash
file_contains_string "$file_path" "$search_string"
```

**Parameters**:
- `$1` - File path
- `$2` - String to search for

**Returns**:
- 0 if string is found
- Non-zero if string is not found or error occurs

#### get_absolute_path
Get the absolute path of a directory or file.

```bash
get_absolute_path "$path"
```

**Parameters**:
- `$1` - Path to convert

**Returns**:
- 0 on success, outputs absolute path to stdout
- Non-zero on error

#### safe_copy
Safely copy files with error handling.

```bash
safe_copy "$src" "$dst"
```

**Parameters**:
- `$1` - Source path
- `$2` - Destination path

**Returns**:
- 0 on success
- Non-zero on error

#### validate_workspace_path
Validate workspace path to prevent directory traversal.

```bash
validate_workspace_path "$path"
```

**Parameters**:
- `$1` - Path to validate

**Returns**:
- 0 if valid
- Non-zero if invalid

#### escape_for_sed
Escape special characters in strings for use with sed.

```bash
escape_for_sed "$string"
```

**Parameters**:
- `$1` - String to escape

**Returns**:
- 0 on success, outputs escaped string to stdout
- Non-zero on error

## Data Structures

### Workspace State File
Each workspace contains a `.devmorph-state` file with the following structure:

```json
{
  "name": "workspace-name",
  "template": "template-name",
  "mode": "current-mode",
  "created_at": "2023-01-01T00:00:00Z",
  "status": "created|configured|running|stopped"
}
```

### Global Configuration File
Stored in `$XDG_CONFIG_HOME/devmorph/config.json` or `$HOME/.config/devmorph/config.json`:

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

### Workspace Configuration File
Stored in `workspace-path/.devmorph/config.json`:

```json
{
  "workspace": {
    "name": "workspace-name",
    "template": "template-name",
    "mode": "current-mode",
    "created_at": "2023-01-01T00:00:00Z",
    "status": "created|configured|running|stopped"
  },
  "docker": {
    "compose_file": "docker-compose.yml",
    "auto_prune": true
  },
  "paths": {
    "workspace_root": "/absolute/path/to/workspace",
    "templates_dir": "../../../templates"
  }
}
```

## Environment Variables

### DEVMORPH_LOG_LEVEL
Set the logging level.

**Values**: debug, info, warn, error
**Default**: info

### DEVMORPH_DEBUG
Enable debug mode.

**Values**: 1 (enabled), 0 (disabled)
**Default**: 0

### XDG_CONFIG_HOME
Override the default configuration directory location.

**Default**: $HOME/.config

### DOCKER_HOST
Specify the Docker daemon socket or URL.

**Default**: unix:///var/run/docker.sock

## Error Codes

### General Error Codes
- **0**: Success
- **1**: General error
- **2**: Misuse of shell builtins
- **126**: Command invoked cannot execute
- **127**: Command not found
- **128+n**: Fatal error signal "n"

### Custom Error Codes
- **10**: Invalid workspace name
- **11**: Invalid template name
- **12**: Invalid mode
- **13**: Workspace already exists
- **14**: Workspace does not exist
- **15**: Docker not available
- **16**: Docker Compose not available
- **17**: Configuration file error
- **18**: Permission denied
- **19**: Path traversal detected
- **20**: Invalid input parameter

---

*Last updated: July 03, 2025*