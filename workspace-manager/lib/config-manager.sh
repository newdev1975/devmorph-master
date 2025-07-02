#!/bin/sh
# Configuration Manager Library for DevMorph AI Studio
# Provides functionality to manage application and workspace configurations

# Exit on error
set -e

# Source required libraries
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
. "$SCRIPT_DIR/logger.sh"
. "$SCRIPT_DIR/helpers.sh"
. "$SCRIPT_DIR/validator.sh"

# Function to read configuration value from JSON
# Arguments:
# $1 - Config file path
# $2 - Key to read
read_config_value() {
    config_file="$1"
    key="$2"
    
    if [ ! -f "$config_file" ]; then
        log_warn "Config file does not exist: $config_file"
        return 1
    fi
    
    # Extract value for the given key from JSON file
    result=$(grep "\"$key\"" "$config_file" 2>/dev/null | sed 's/.*"'$key'":[[:space:]]*"\([^"]*\)".*/\1/' 2>/dev/null)
    if [ -n "$result" ]; then
        echo "$result"
        return 0
    fi
    
    # Try numeric value
    result=$(grep "\"$key\"" "$config_file" 2>/dev/null | sed 's/.*"'$key'":[[:space:]]*[0-9]*/\1/' 2>/dev/null)
    if [ -n "$result" ]; then
        echo "$result"
        return 0
    fi
    
    # Try boolean value
    result=$(grep "\"$key\"" "$config_file" 2>/dev/null | sed 's/.*"'$key'":[[:space:]]*true/\1/' 2>/dev/null)
    if [ -n "$result" ]; then
        echo "true"
        return 0
    fi
    
    result=$(grep "\"$key\"" "$config_file" 2>/dev/null | sed 's/.*"'$key'":[[:space:]]*false/\1/' 2>/dev/null)
    if [ -n "$result" ]; then
        echo "false"
        return 0
    fi
    
    return 1
}

# Function to write configuration value to JSON
# Arguments:
# $1 - Config file path
# $2 - Key to write
# $3 - Value to write
write_config_value() {
    config_file="$1"
    key="$2"
    value="$3"
    
    if [ ! -f "$config_file" ]; then
        # Create basic JSON structure if file doesn't exist
        echo "{" > "$config_file"
        echo "  \"$key\": \"$value\"" >> "$config_file"
        echo "}" >> "$config_file"
        return 0
    fi
    
    # Check if key exists in config
    if grep -q "\"$key\"" "$config_file"; then
        # Update existing key
        tmp_file=$(mktemp)
        sed "s/\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"$key\": \"$value\"/" "$config_file" > "$tmp_file"
        mv "$tmp_file" "$config_file"
    else
        # Add new key before closing bracket
        tmp_file=$(mktemp)
        sed "/}.*$/s/^/  \"$key\": \"$value\",\n/" "$config_file" > "$tmp_file"
        mv "$tmp_file" "$config_file"
    fi
}

# Function to initialize workspace configuration
# Arguments:
# $1 - Workspace path
# $2 - Workspace name
# $3 - Template name
# $4 - Mode
initialize_workspace_config() {
    workspace_path="$1"
    workspace_name="$2"
    template_name="$3"
    mode="$4"
    
    # Validate inputs
    if ! validate_workspace_name "$workspace_name"; then
        log_error "Invalid workspace name: $workspace_name"
        return 1
    fi
    
    if ! validate_template_name "$template_name"; then
        log_error "Invalid template name: $template_name"
        return 1
    fi

    config_file="$workspace_path/.devmorph/config.json"
    mkdir -p "$(dirname "$config_file")"
    
    cat > "$config_file" << EOF
{
  "workspace": {
    "name": "$workspace_name",
    "template": "$template_name",
    "mode": "$mode",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "status": "created"
  },
  "docker": {
    "compose_file": "docker-compose.yml",
    "auto_prune": true
  },
  "paths": {
    "workspace_root": "$workspace_path",
    "templates_dir": "../../../templates"
  }
}
EOF

    log_info "Initialized configuration for workspace '$workspace_name' at $config_file"
}

# Function to update workspace configuration
# Arguments:
# $1 - Workspace path
# $2 - Key to update
# $3 - Value to set
update_workspace_config() {
    workspace_path="$1"
    key="$2"
    value="$3"
    
    config_file="$workspace_path/.devmorph/config.json"
    
    if [ ! -f "$config_file" ]; then
        log_error "Config file does not exist: $config_file" >&2
        return 1
    fi
    
    write_config_value "$config_file" "$key" "$value"
    log_info "Updated configuration for workspace at $config_file: $key = $value"
}

# Function to load workspace configuration
# Arguments:
# $1 - Workspace path
load_workspace_config() {
    workspace_path="$1"
    config_file="$workspace_path/.devmorph/config.json"
    
    if [ -f "$config_file" ]; then
        # Source config values as environment variables
        # This is a simplified approach - in a more complex system we'd parse JSON properly
        WORKSPACE_NAME=$(read_config_value "$config_file" "name" 2>/dev/null || echo "")
        WORKSPACE_MODE=$(read_config_value "$config_file" "mode" 2>/dev/null || echo "")
        WORKSPACE_STATUS=$(read_config_value "$config_file" "status" 2>/dev/null || echo "")

        log_info "Workspace configuration loaded: $workspace_path"
    else
        log_warn "Config file does not exist: $config_file" 
    fi
}

# Function to get global config directory
get_global_config_dir() {
    # Use XDG config directory or fallback to home directory
    if [ -n "$XDG_CONFIG_HOME" ]; then
        echo "$XDG_CONFIG_HOME/devmorph"
    else
        echo "$HOME/.config/devmorph"
    fi
}

# Function to initialize global configuration
initialize_global_config() {
    config_dir=$(get_global_config_dir)
    mkdir -p "$config_dir"
    
    config_file="$config_dir/config.json"
    
    # Only create if it doesn't exist
    if [ ! -f "$config_file" ]; then
        cat > "$config_file" << EOF
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
EOF
        log_info "Initialized global configuration at $config_file"
    else
        log_info "Global configuration already exists at $config_file"
    fi
}