#!/bin/sh
# Docker Manager Library for DevMorph AI Studio
# Provides functionality to manage Docker containers for workspaces

# Exit on error
set -e

# Function to check if Docker is available
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: Docker is not installed or not in PATH" >&2
        return 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker daemon is not running" >&2
        return 1
    fi
    
    return 0
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose >/dev/null 2>&1 && ! (docker --help 2>/dev/null | grep -q compose); then
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
    
    echo "Starting workspace: $(basename "$workspace_path")"
    
    # Change to workspace directory and start services
    cd "$workspace_path"
    if command -v docker-compose >/dev/null 2>&1; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
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
    
    echo "Stopping workspace: $(basename "$workspace_path")"
    
    # Change to workspace directory and stop services
    cd "$workspace_path"
    if command -v docker-compose >/dev/null 2>&1; then
        docker-compose down
    else
        docker compose down
    fi
    
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
        # Read existing state, update status field
        tmp_file=$(mktemp)
        sed "s/\"status\": \"[^\"]*\"/\"status\": \"$new_state\"/" "$state_file" > "$tmp_file"
        mv "$tmp_file" "$state_file"
    fi
}