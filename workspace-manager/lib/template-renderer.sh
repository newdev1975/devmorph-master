#!/bin/sh
# Template Renderer Library for DevMorph AI Studio
# Provides functionality to render templates from /templates/ directory

# Exit on error
set -e

# Source helpers library for path validation
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"
if [ -f "$LIB_DIR/helpers.sh" ]; then
    . "$LIB_DIR/helpers.sh"
fi

# Function to render a template using environment variables
# Arguments:
# $1 - Template file path
# $2 - Output file path
render_template() {
    template_path="$1"
    output_path="$2"
    
    # Validate template path to prevent directory traversal
    if command -v validate_workspace_path >/dev/null 2>&1; then
        if ! validate_workspace_path "$template_path"; then
            echo "Error: Invalid template path: $template_path" >&2
            return 1
        fi
    fi
    
    if [ ! -f "$template_path" ]; then
        echo "Error: Template file does not exist: $template_path" >&2
        return 1
    fi
    
    # Validate that the template file is readable
    if [ ! -r "$template_path" ]; then
        echo "Error: Template file is not readable: $template_path" >&2
        return 1
    fi
    
    # Ensure output directory exists
    output_dir=$(dirname "$output_path")
    if [ ! -d "$output_dir" ]; then
        if ! mkdir -p "$output_dir"; then
            echo "Error: Failed to create output directory: $output_dir" >&2
            return 1
        fi
    fi
    
    # Copy template to output, replacing environment variables
    # This uses POSIX-compliant parameter expansion instead of bash-specific features
    if ! while IFS= read -r line; do
        # Replace ${VAR} patterns with environment variable values
        eval "echo \"$line\""
    done < "$template_path" > "$output_path"; then
        echo "Error: Failed to render template: $template_path" >&2
        return 1
    fi
    
    return 0
}

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

# Function to check if workspace already exists
# Arguments:
# $1 - Workspace name
workspace_exists() {
    name="$1"
    workspace_path="./$name"
    
    # Additional validation to prevent directory traversal
    case "$name" in
        */*|*../*|*/*..|*\.\./*)
            echo "Error: Workspace name contains invalid path characters" >&2
            return 1
            ;;
    esac
    
    if [ -d "$workspace_path" ]; then
        return 0
    else
        return 1
    fi
}

# Function to validate template path
# Arguments:
# $1 - Template path to validate
validate_template_path() {
    template_path="$1"
    
    if [ -z "$template_path" ]; then
        echo "Error: Template path cannot be empty" >&2
        return 1
    fi
    
    # Check for dangerous patterns
    case "$template_path" in
        */..|*../|*../*|/*|../*)
            echo "Error: Template path contains dangerous traversal patterns" >&2
            return 1
            ;;
    esac
    
    # Validate against allowed directories
    case "$template_path" in
        ../templates/*|./templates/*|templates/*)
            # Valid template paths
            ;;
        *)
            echo "Error: Template path is not in allowed templates directory: $template_path" >&2
            return 1
            ;;
    esac
    
    return 0
}