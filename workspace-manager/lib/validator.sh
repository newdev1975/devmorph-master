#!/bin/sh
# Validator Library for DevMorph AI Studio
# Provides validation functions for inputs and data

# Exit on error
set -e

# Function to validate workspace name
# Arguments:
# $1 - Workspace name to validate
validate_workspace_name() {
    name="$1"
    
    # Check if name is provided
    if [ -z "$name" ]; then
        echo "Error: Workspace name cannot be empty" >&2
        return 1
    fi
    
    # Check if name contains only alphanumeric characters, hyphens, and underscores
    if ! echo "$name" | grep -qE '^[a-zA-Z0-9_-]+$'; then
        echo "Error: Workspace name can only contain alphanumeric characters, hyphens, and underscores" >&2
        return 1
    fi
    
    # Check if name is too short (minimum 1 character)
    if [ ${#name} -lt 1 ]; then
        echo "Error: Workspace name too short (min 1 character)" >&2
        return 1
    fi
    
    # Check length (1-64 characters)
    if [ ${#name} -gt 64 ]; then
        echo "Error: Workspace name too long (max 64 characters)" >&2
        return 1
    fi
    
    # Check for reserved names
    case "$name" in
        "."|".."|"/")
            echo "Error: Workspace name is a reserved name" >&2
            return 1
            ;;
    esac
    
    return 0
}

# Function to validate template name
# Arguments:
# $1 - Template name to validate
validate_template_name() {
    template="$1"
    
    if [ -z "$template" ]; then
        echo "Error: Template name cannot be empty" >&2
        return 1
    fi
    
    if ! echo "$template" | grep -qE '^[a-zA-Z0-9_-]+$'; then
        echo "Error: Template name can only contain alphanumeric characters, hyphens, and underscores" >&2
        return 1
    fi
    
    if [ ${#template} -lt 1 ]; then
        echo "Error: Template name too short (min 1 character)" >&2
        return 1
    fi
    
    if [ ${#template} -gt 64 ]; then
        echo "Error: Template name too long (max 64 characters)" >&2
        return 1
    fi
    
    # Check for reserved names
    case "$template" in
        "."|".."|"/")
            echo "Error: Template name is a reserved name" >&2
            return 1
            ;;
    esac
    
    return 0
}

# Function to validate path
# Arguments:
# $1 - Path to validate
validate_path() {
    path="$1"
    
    if [ -z "$path" ]; then
        echo "Error: Path cannot be empty" >&2
        return 1
    fi
    
    # Check for dangerous patterns
    case "$path" in
        */..|*../|*../*|/*|../*)
            echo "Error: Path contains dangerous traversal patterns" >&2
            return 1
            ;;
    esac
    
    # On Windows, paths can have different format, but we're focusing on POSIX
    # Check for invalid characters (we're being permissive here)
    case "$path" in
        *../*|*/../*|*/..) 
            echo "Error: Path cannot contain '/../'" >&2
            return 1
            ;;
        /*/*/../|/*/*/../) 
            echo "Error: Path cannot contain '/../'" >&2
            return 1
            ;;
    esac
    
    return 0
}

# Function to validate if directory exists
# Arguments:
# $1 - Directory path to check
validate_directory_exists() {
    dir_path="$1"
    
    if [ ! -d "$dir_path" ]; then
        echo "Error: Directory does not exist: $dir_path" >&2
        return 1
    fi
    
    # Additional check: ensure directory is readable
    if [ ! -r "$dir_path" ]; then
        echo "Error: Directory is not readable: $dir_path" >&2
        return 1
    fi
    
    return 0
}

# Function to validate if file exists
# Arguments:
# $1 - File path to check
validate_file_exists() {
    file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        echo "Error: File does not exist: $file_path" >&2
        return 1
    fi
    
    # Additional check: ensure file is readable
    if [ ! -r "$file_path" ]; then
        echo "Error: File is not readable: $file_path" >&2
        return 1
    fi
    
    return 0
}

# Function to validate Docker Compose file
# Arguments:
# $1 - Docker Compose file path
validate_docker_compose_file() {
    compose_file="$1"
    
    if [ ! -f "$compose_file" ]; then
        echo "Error: Docker Compose file does not exist: $compose_file" >&2
        return 1
    fi
    
    # Check if file has valid extension
    case "$compose_file" in
        *.yml|*.yaml)
            ;;
        *)
            echo "Error: Docker Compose file must have .yml or .yaml extension: $compose_file" >&2
            return 1
            ;;
    esac
    
    # Check if file is readable
    if [ ! -r "$compose_file" ]; then
        echo "Error: Docker Compose file is not readable: $compose_file" >&2
        return 1
    fi
    
    return 0
}

# Function to validate mode
# Arguments:
# $1 - Mode name to validate
validate_mode() {
    mode="$1"
    
    if [ -z "$mode" ]; then
        echo "Error: Mode cannot be empty" >&2
        return 1
    fi
    
    # Check against allowed modes
    case "$mode" in
        "dev"|"prod"|"staging"|"test"|"design"|"mix")
            return 0
            ;;
        *)
            echo "Error: Invalid mode '$mode'. Valid modes: dev, prod, staging, test, design, mix" >&2
            return 1
            ;;
    esac
}