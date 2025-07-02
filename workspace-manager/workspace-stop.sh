#!/bin/sh
# Workspace Stop Script for DevMorph AI Studio
# Handles stopping workspace containers

# Exit on error
set -e

# Source the docker manager library
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"
. "$LIB_DIR/docker-manager.sh"

# Default values
WORKSPACE_NAME=""

# Function to display usage
usage() {
    echo "Usage: $0 <workspace-name>"
    echo "  workspace-name: Name of the workspace to stop (required)"
    echo "  --help: Display this help message"
    exit 1
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            usage
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            if [ -z "$WORKSPACE_NAME" ]; then
                WORKSPACE_NAME="$1"
            else
                echo "Error: Too many arguments" >&2
                usage
            fi
            ;;
    esac
    shift
done

# Validate required parameters
if [ -z "$WORKSPACE_NAME" ]; then
    echo "Error: Workspace name is required" >&2
    usage
fi

# Validate workspace name format
if ! echo "$WORKSPACE_NAME" | grep -qE '^[a-zA-Z0-9_-]+$'; then
    echo "Error: Workspace name can only contain alphanumeric characters, 
      hyphens, and underscores" >&2
    exit 1
fi

# Check if workspace exists
if [ ! -d "$WORKSPACE_NAME" ]; then
    echo "Error: Workspace '$WORKSPACE_NAME' does not exist" >&2
    exit 1
fi

# Check Docker and Docker Compose availability
if ! check_docker; then
    exit 1
fi

if ! check_docker_compose; then
    exit 1
fi

# Stop the workspace
if stop_workspace "$WORKSPACE_NAME"; then
    echo "Workspace '$WORKSPACE_NAME' stopped successfully"
else
    echo "Failed to stop workspace '$WORKSPACE_NAME'" >&2
    exit 1
fi