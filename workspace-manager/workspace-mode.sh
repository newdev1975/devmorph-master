#!/bin/sh
# Workspace Mode Script for DevMorph AI Studio
# Handles workspace mode management (set/show)

# Exit on error
set -e

# Source the mode handler library
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"
. "$LIB_DIR/mode-handler.sh"

# Default values
SUBCOMMAND=""
WORKSPACE_NAME=""
NEW_MODE=""

# Function to display usage
usage() {
    echo "Usage: $0 (set|show) <workspace-name> [--mode <mode>]"
    echo "  set: Set mode for a workspace"
    echo "  show: Show current mode of a workspace"
    echo "  workspace-name: Name of the workspace"
    echo "  --mode: Mode to set (required for 'set' command)"
    echo "  --help: Display this help message"
    exit 1
}

# Check if subcommand is provided
if [ $# -eq 0 ]; then
    usage
fi

# Parse subcommand
SUBCOMMAND="$1"
shift

# Validate subcommand
if [ "$SUBCOMMAND" != "set" ] && [ "$SUBCOMMAND" != "show" ]; then
    echo "Error: Invalid subcommand '$SUBCOMMAND'. Use 'set' or 'show'." >&2
    exit 1
fi

# Parse remaining arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --mode)
            NEW_MODE="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [ -z "$WORKSPACE_NAME" ]; then
                WORKSPACE_NAME="$1"
            else
                echo "Error: Too many arguments" >&2
                exit 1
            fi
            ;;
    esac
    shift
done

# Validate required parameters
if [ -z "$WORKSPACE_NAME" ]; then
    echo "Error: Workspace name is required" >&2
    exit 1
fi

# Validate workspace name format
if ! echo "$WORKSPACE_NAME" | grep -qE '^[a-zA-Z0-9_-]+$'; then
    echo "Error: Workspace name can only contain alphanumeric characters, hyphens, and underscores" >&2
    exit 1
fi

# Check if workspace exists
if [ ! -d "$WORKSPACE_NAME" ]; then
    echo "Error: Workspace '$WORKSPACE_NAME' does not exist" >&2
    exit 1
fi

# Execute based on subcommand
case "$SUBCOMMAND" in
    "set")
        # Validate mode parameter
        if [ -z "$NEW_MODE" ]; then
            echo "Error: --mode is required for 'set' command" >&2
            exit 1
        fi

        # Set the new mode
        if switch_workspace_mode "$WORKSPACE_NAME" "$NEW_MODE"; then
            echo "Mode set successfully for workspace '$WORKSPACE_NAME'"
        else
            echo "Failed to set mode for workspace '$WORKSPACE_NAME'" >&2
            exit 1
        fi
        ;;
    "show")
        # Show current mode
        current_mode=$(get_workspace_mode "$WORKSPACE_NAME")
        echo "Workspace '$WORKSPACE_NAME' is in mode: $current_mode"
        ;;
esac