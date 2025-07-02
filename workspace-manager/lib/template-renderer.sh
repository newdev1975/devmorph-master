#!/bin/sh
# Template Renderer Library for DevMorph AI Studio
# Provides functionality to render templates from /templates/ directory

# Exit on error
set -e

# Function to render a template using environment variables
# Arguments:
# $1 - Template file path
# $2 - Output file path
render_template() {
    template_path="$1"
    output_path="$2"
    
    if [ ! -f "$template_path" ]; then
        echo "Error: Template file does not exist: $template_path" >&2
        return 1
    fi
    
    # Copy template to output, replacing environment variables
    # This uses POSIX-compliant parameter expansion instead of bash-specific features
    while IFS= read -r line; do
        # Replace ${VAR} patterns with environment variable values
        eval "echo \"$line\""
    done < "$template_path" > "$output_path"
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
    
    # Check length (1-64 characters)
    if [ ${#name} -gt 64 ]; then
        echo "Error: Workspace name too long (max 64 characters)" >&2
        return 1
    fi
    
    return 0
}

# Function to check if workspace already exists
# Arguments:
# $1 - Workspace name
workspace_exists() {
    name="$1"
    workspace_path="./$name"
    
    if [ -d "$workspace_path" ]; then
        return 0
    else
        return 1
    fi
}