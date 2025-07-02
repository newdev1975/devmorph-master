#!/bin/sh
# Configuration Manager Library for DevMorph AI Studio
# Provides functionality to manage application and workspace configurations

# Exit on error
set -e

# Source required libraries with error handling
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"

# Validate that all required libraries exist before sourcing
if [ ! -f "$SCRIPT_DIR/logger.sh" ]; then
    echo "ERROR [$(basename "$0")] Logger library not found: $SCRIPT_DIR/logger.sh" >&2
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/helpers.sh" ]; then
    echo "ERROR [$(basename "$0")] Helpers library not found: $SCRIPT_DIR/helpers.sh" >&2
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/validator.sh" ]; then
    echo "ERROR [$(basename "$0")] Validator library not found: $SCRIPT_DIR/validator.sh" >&2
    exit 1
fi

# Source all libraries
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
    
    # Validate that the file is readable
    if [ ! -r "$config_file" ]; then
        log_error "Config file is not readable: $config_file"
        return 1
    fi
    
    # Extract value for the given key from JSON file using more robust method
    result=$(grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$config_file" 2>/dev/null | sed 's/.*"//' | sed 's/"$//' | head -n 1)
    if [ -n "$result" ]; then
        echo "$result"
        return 0
    fi
    
    # Try numeric value
    result=$(grep -o "\"$key\"[[:space:]]*:[[:space:]]*[0-9]*" "$config_file" 2>/dev/null | sed 's/.*:[[:space:]]*//' | head -n 1)
    if [ -n "$result" ]; then
        echo "$result"
        return 0
    fi
    
    # Try boolean or null values
    result=$(grep -o "\"$key\"[[:space:]]*:[[:space:]]*[a-z]*" "$config_file" 2>/dev/null | sed 's/.*:[[:space:]]*//' | head -n 1)
    if [ -n "$result" ] && [ "$result" != "$key" ]; then
        echo "$result"
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
    
    # Validate that the key doesn't contain problematic characters
    case "$key" in
        *\"*|*$'*'|*\\*)
            log_error "Key contains invalid characters: $key"
            return 1
            ;;
    esac
    
    # Validate that the value doesn't contain problematic characters
    case "$value" in
        *\"*|*$'*'|*\\*)
            log_error "Value contains invalid characters: $value"
            return 1
            ;;
    esac
    
    if [ ! -f "$config_file" ]; then
        # Create basic JSON structure if file doesn't exist
        echo "{" > "$config_file"
        echo "  \"$key\": \"$value\"" >> "$config_file"
        echo "}" >> "$config_file"
        return 0
    fi
    
    # Check if key exists in config
    if grep -q "\"$key\"" "$config_file"; then
        # Update existing key with atomic operation
        tmp_file=$(mktemp)
        if sed "s/\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"$key\": \"$value\"/" "$config_file" > "$tmp_file" 2>/dev/null; then
            mv "$tmp_file" "$config_file"
        else
            # If sed fails, try to handle numeric/boolean values
            rm -f "$tmp_file"
            tmp_file=$(mktemp)
            if sed "s/\"$key\"[[:space:]]*:[[:space:]]*[a-zA-Z0-9_]*/\"$key\": \"$value\"/" "$config_file" > "$tmp_file" 2>/dev/null; then
                mv "$tmp_file" "$config_file"
            else
                rm -f "$tmp_file"
                log_error "Failed to update config value"
                return 1
            fi
        fi
    else
        # Add new key before closing bracket with atomic operation
        tmp_file=$(mktemp)
        if sed "/}.*$/s/^/  \"$key\": \"$value\",\n/" "$config_file" > "$tmp_file" 2>/dev/null; then
            mv "$tmp_file" "$config_file"
        else
            rm -f "$tmp_file"
            log_error "Failed to add config value"
            return 1
        fi
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
    
    # Validate workspace path to prevent directory traversal
    if ! validate_workspace_path "$workspace_path"; then
        log_error "Invalid workspace path: $workspace_path"
        return 1
    fi
    
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
    
    # Create config directory atomically
    if ! mkdir -p "$(dirname "$config_file")" 2>/dev/null; then
        log_error "Failed to create config directory: $(dirname "$config_file")"
        return 1
    fi
    
    # Create configuration file with atomic write
    tmp_file=$(mktemp)
    cat > "$tmp_file" << EOF
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
    
    if ! mv "$tmp_file" "$config_file"; then
        rm -f "$tmp_file"
        log_error "Failed to write config file: $config_file"
        return 1
    fi

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
    
    # Validate workspace path to prevent directory traversal
    if ! validate_workspace_path "$workspace_path"; then
        log_error "Invalid workspace path: $workspace_path"
        return 1
    fi
    
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
    
    # Create config directory with proper permissions
    if ! mkdir -p "$config_dir"; then
        log_error "Failed to create config directory: $config_dir" >&2
        return 1
    fi
    
    config_file="$config_dir/config.json"
    
    # Only create if it doesn't exist
    if [ ! -f "$config_file" ]; then
        # Create with atomic write
        tmp_file=$(mktemp)
        cat > "$tmp_file" << EOF
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
        
        if ! mv "$tmp_file" "$config_file"; then
            rm -f "$tmp_file"
            log_error "Failed to create global config file"
            return 1
        fi
        log_info "Initialized global configuration at $config_file"
    else
        log_info "Global configuration already exists at $config_file"
    fi
}

# Function to validate configuration file structure
# Arguments:
# $1 - Config file path
validate_config_file() {
    config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        log_error "Config file does not exist: $config_file"
        return 1
    fi
    
    if [ ! -r "$config_file" ]; then
        log_error "Config file is not readable: $config_file"
        return 1
    fi
    
    # Basic validation: check if file has JSON-like structure
    if ! grep -q '{' "$config_file" || ! grep -q '}' "$config_file"; then
        log_error "Config file doesn't appear to be valid JSON: $config_file"
        return 1
    fi
    
    return 0
}