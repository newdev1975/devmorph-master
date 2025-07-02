#!/bin/sh
# Mode Handler Library for DevMorph AI Studio
# Provides functionality to manage workspace modes

# Exit on error
set -e

# Source helpers library for path validation
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"
if [ -f "$LIB_DIR/helpers.sh" ]; then
    . "$LIB_DIR/helpers.sh"
fi

# Function to get available modes
get_available_modes() {
    SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
    MODES_DIR="$SCRIPT_DIR/modes"
    
    if [ -d "$MODES_DIR" ]; then
        ls -1 "$MODES_DIR" 2>/dev/null | grep -E '^(dev|prod|staging|test|design|mix)$' || true
    fi
}

# Function to validate mode
# Arguments:
# $1 - Mode name to validate
validate_mode() {
    mode="$1"
    available_modes=$(get_available_modes)
    
    if echo "$available_modes" | grep -q "^$mode$"; then
        return 0
    else
        return 1
    fi
}

# Function to get mode configuration path
# Arguments:
# $1 - Mode name
get_mode_path() {
    mode="$1"
    SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
    echo "$SCRIPT_DIR/modes/$mode"
}

# Function to switch mode for a workspace
# Arguments:
# $1 - Workspace path
# $2 - New mode
switch_workspace_mode() {
    workspace_path="$1"
    new_mode="$2"
    state_file="$workspace_path/.devmorph-state"
    
    # Validate workspace path to prevent directory traversal
    if command -v validate_workspace_path >/dev/null 2>&1; then
        if ! validate_workspace_path "$workspace_path"; then
            echo "Error: Invalid workspace path: $workspace_path" >&2
            return 1
        fi
    fi
    
    # Validate mode
    if ! validate_mode "$new_mode"; then
        echo "Error: Invalid mode '$new_mode'" >&2
        return 1
    fi
    
    # Get current mode from state file
    current_mode=""
    if [ -f "$state_file" ]; then
        # Extract mode from JSON state file
        current_mode=$(grep '"mode"' "$state_file" 2>/dev/null | sed -n 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
    fi
    
    # If workspace is running, we might need to handle the change appropriately
    current_status=""
    if [ -f "$state_file" ]; then
        current_status=$(grep '"status"' "$state_file" 2>/dev/null | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
    fi
    
    if [ "$current_status" = "running" ]; then
        echo "Warning: Workspace is currently running. Mode change will take effect on next start." >&2
    fi
    
    # Update the mode in the state file with atomic operation
    if [ -f "$state_file" ]; then
        tmp_file=$(mktemp)
        if sed "s/\"mode\": \"[^\"]*\"/\"mode\": \"$new_mode\"/" "$state_file" > "$tmp_file" 2>/dev/null; then
            mv "$tmp_file" "$state_file"
        else
            echo "Error: Failed to update mode in state file" >&2
            rm -f "$tmp_file"
            return 1
        fi
    else
        # Create state file if it doesn't exist
        # Ensure parent directory exists
        mkdir -p "$(dirname "$state_file")"
        
        cat > "$state_file" << EOF
{
  "name": "$(basename "$workspace_path")",
  "template": "unknown",
  "mode": "$new_mode",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "status": "configured"
}
EOF
    fi
    
    # Copy mode-specific files to workspace (with override) using safe method
    mode_path=$(get_mode_path "$new_mode")
    if [ -d "$mode_path" ]; then
        # Use safer copy method
        (cd "$mode_path" && tar cf - .) | (cd "$workspace_path" && tar xf -)
    fi
    
    echo "Mode changed to '$new_mode' for workspace: $(basename "$workspace_path")"
    return 0
}

# Function to get current mode of a workspace
# Arguments:
# $1 - Workspace path
get_workspace_mode() {
    workspace_path="$1"
    state_file="$workspace_path/.devmorph-state"
    
    if [ -f "$state_file" ]; then
        # Extract mode from JSON state file using more robust method
        mode=$(grep '"mode"' "$state_file" 2>/dev/null | sed -n 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
        if [ -n "$mode" ]; then
            echo "$mode"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Function to get current mode of a workspace in a more robust way
# Arguments:
# $1 - Workspace path
get_workspace_mode_safe() {
    workspace_path="$1"
    state_file="$workspace_path/.devmorph-state"
    
    if [ -f "$state_file" ]; then
        # Extract mode from JSON state file using safer method
        # Look for mode value after "mode" key and colon, handling potential spacing
        mode=$(grep -o '"mode"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null | sed 's/.*"[^"]*"$//' | sed 's/.*"//')
        if [ -n "$mode" ]; then
            echo "$mode"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}