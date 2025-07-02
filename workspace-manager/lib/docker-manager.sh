#!/bin/sh
# Docker Manager Library for DevMorph AI Studio
# Provides functionality to manage Docker containers for workspaces

# Exit on error
set -e

# Source helpers library for path validation
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"
if [ -f "$LIB_DIR/helpers.sh" ]; then
    . "$LIB_DIR/helpers.sh"
fi

# Function to check if Docker is available
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: Docker is not installed or not in PATH" >&2
        return 1
    fi
    
    # Additional check to ensure Docker daemon is responsive
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker daemon is not running" >&2
        return 1
    fi
    
    return 0
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose >/dev/null 2>&1 && ! (command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1); then
        echo "Error: Docker Compose is not installed or not in PATH" >&2
        return 1
    fi
    
    return 0
}

# Function to start a workspace
# Arguments:
# $1 - Workspace path
start_workspace() {
    workspace_path="$1"
    
    # Validate workspace path to prevent directory traversal
    if command -v validate_workspace_path >/dev/null 2>&1; then
        if ! validate_workspace_path "$workspace_path"; then
            echo "Error: Invalid workspace path: $workspace_path" >&2
            return 1
        fi
    fi
    
    if [ ! -d "$workspace_path" ]; then
        echo "Error: Workspace directory does not exist: $workspace_path" >&2
        return 1
    fi
    
    # Check if docker-compose.yml exists in workspace
    compose_file="$workspace_path/docker-compose.yml"
    if [ ! -f "$compose_file" ]; then
        compose_file="$workspace_path/docker-compose.yaml"
        if [ ! -f "$compose_file" ]; then
            echo "Error: Neither docker-compose.yml nor docker-compose.yaml found in workspace" >&2
            return 1
        fi
    fi
    
    # Additional check: verify the compose file is valid
    if ! [ -r "$compose_file" ]; then
        echo "Error: Docker Compose file is not readable: $compose_file" >&2
        return 1
    fi
    
    echo "Starting workspace: $(basename "$workspace_path")"
    
    # Change to workspace directory and start services
    # Use a subshell to avoid changing the current directory permanently
    (
        cd "$workspace_path"
        if command -v docker-compose >/dev/null 2>&1; then
            if ! docker-compose up -d; then
                echo "Error: Failed to start Docker Compose services" >&2
                return 1
            fi
        else
            if ! docker compose up -d; then
                echo "Error: Failed to start Docker Compose services" >&2
                return 1
            fi
        fi
    )
    
    # Update workspace state
    update_workspace_state "$workspace_path" "running"
    
    echo "Workspace started successfully"
    return 0
}

# Function to stop a workspace
# Arguments:
# $1 - Workspace path
stop_workspace() {
    workspace_path="$1"
    
    # Validate workspace path to prevent directory traversal
    if command -v validate_workspace_path >/dev/null 2>&1; then
        if ! validate_workspace_path "$workspace_path"; then
            echo "Error: Invalid workspace path: $workspace_path" >&2
            return 1
        fi
    fi
    
    if [ ! -d "$workspace_path" ]; then
        echo "Error: Workspace directory does not exist: $workspace_path" >&2
        return 1
    fi
    
    # Check if docker-compose.yml exists in workspace
    compose_file="$workspace_path/docker-compose.yml"
    if [ ! -f "$compose_file" ]; then
        compose_file="$workspace_path/docker-compose.yaml"
        if [ ! -f "$compose_file" ]; then
            echo "Error: Neither docker-compose.yml nor docker-compose.yaml found in workspace" >&2
            return 1
        fi
    fi
    
    # Additional check: verify the compose file is readable
    if ! [ -r "$compose_file" ]; then
        echo "Error: Docker Compose file is not readable: $compose_file" >&2
        return 1
    fi
    
    echo "Stopping workspace: $(basename "$workspace_path")"
    
    # Change to workspace directory and stop services
    # Use a subshell to avoid changing the current directory permanently
    (
        cd "$workspace_path"
        if command -v docker-compose >/dev/null 2>&1; then
            if ! docker-compose down; then
                echo "Warning: Failed to stop Docker Compose services, but continuing" >&2
                # Don't fail here, as services might not be running
            fi
        else
            if ! docker compose down; then
                echo "Warning: Failed to stop Docker Compose services, but continuing" >&2
                # Don't fail here, as services might not be running
            fi
        fi
    )
    
    # Update workspace state
    update_workspace_state "$workspace_path" "stopped"
    
    echo "Workspace stopped successfully"
    return 0
}

# Function to update workspace state
# Arguments:
# $1 - Workspace path
# $2 - New state
update_workspace_state() {
    workspace_path="$1"
    new_state="$2"
    
    state_file="$workspace_path/.devmorph-state"
    if [ -f "$state_file" ]; then
        # Use temporary file for atomic update
        tmp_file=$(mktemp)
        if sed "s/\"status\": \"[^\"]*\"/\"status\": \"$new_state\"/" "$state_file" > "$tmp_file" 2>/dev/null; then
            mv "$tmp_file" "$state_file"
        else
            # If sed fails, recreate the file with the new status
            rm -f "$tmp_file"
            echo "Warning: Failed to update status in state file" >&2
        fi
    fi
}

# Function to check if workspace is running
# Arguments:
# $1 - Workspace path
is_workspace_running() {
    workspace_path="$1"
    
    if [ ! -d "$workspace_path" ]; then
        return 1
    fi
    
    # Check if docker-compose.yml exists in workspace
    compose_file="$workspace_path/docker-compose.yml"
    if [ ! -f "$compose_file" ]; then
        compose_file="$workspace_path/docker-compose.yaml"
        if [ ! -f "$compose_file" ]; then
            return 1
        fi
    fi
    
    # Use a subshell to avoid changing the current directory permanently
    (
        cd "$workspace_path"
        if command -v docker-compose >/dev/null 2>&1; then
            docker-compose ps --format "table {{.Status}}" 2>/dev/null | grep -q "Up\|Running" 
        else
            docker compose ps --format "table {{.Status}}" 2>/dev/null | grep -q "Up\|Running"
        fi
    )
}