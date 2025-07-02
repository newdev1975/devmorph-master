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
    
    # Check length (1-64 characters)
    if [ ${#name} -gt 64 ]; then
        echo "Error: Workspace name too long (max 64 characters)" >&2
        return 1
    fi
    
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
    
    if [ ${#template} -gt 64 ]; then
        echo "Error: Template name too long (max 64 characters)" >&2
        return 1
    fi
    
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
    
    return 0
}