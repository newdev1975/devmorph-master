#!/bin/sh
# Workspace Destroy Script for DevMorph AI Studio
# Handles destroying workspace containers and files

# Exit on error
set -e

# Source the required libraries with error handling
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"

# Check if library files exist before sourcing
if [ ! -f "$LIB_DIR/docker-manager.sh" ]; then
    echo "ERROR [$(basename "$0")] Docker manager library not found: $LIB_DIR/docker-manager.sh" >&2
    exit 1
fi

if [ ! -f "$LIB_DIR/validator.sh" ]; then
    echo "ERROR [$(basename "$0")] Validator library not found: $LIB_DIR/validator.sh" >&2
    exit 1
fi

if [ ! -f "$LIB_DIR/logger.sh" ]; then
    echo "ERROR [$(basename "$0")] Logger library not found: $LIB_DIR/logger.sh" >&2
    exit 1
fi

if [ ! -f "$LIB_DIR/helpers.sh" ]; then
    echo "ERROR [$(basename "$0")] Helpers library not found: $LIB_DIR/helpers.sh" >&2
    exit 1
fi

# Source all libraries
. "$LIB_DIR/docker-manager.sh"
. "$LIB_DIR/validator.sh"
. "$LIB_DIR/logger.sh"
. "$LIB_DIR/helpers.sh"

# Initialize logging
initialize_logger

# Default values
WORKSPACE_NAME=""
FORCE=false

# Function to display usage
usage() {
    log_info "Displaying workspace destroy usage information"
    echo "Usage: $0 <workspace-name> [--force]"
    echo "  workspace-name: Name of the workspace to destroy (required)"
    echo "  --force: Force destroy without confirmation"
    echo "  --help: Display this help message"
    exit 0
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            usage
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            if [ -z "$WORKSPACE_NAME" ]; then
                WORKSPACE_NAME="$1"
            else
                log_error "Too many arguments"
                usage
            fi
            ;;
    esac
    shift
done

# Validate required parameters
if [ -z "$WORKSPACE_NAME" ]; then
    log_error "Workspace name is required"
    usage
fi

# Additional security check to prevent directory traversal
case "$WORKSPACE_NAME" in
    */*|*../*|*/*..|*\.\./*)
        log_error "Workspace name contains invalid path characters"
        exit 1
        ;;
esac

# Validate workspace name format using validator library
if ! validate_workspace_name "$WORKSPACE_NAME"; then
    log_error "Invalid workspace name: $WORKSPACE_NAME"
    exit 1
fi

# Check if workspace exists
if [ ! -d "$WORKSPACE_NAME" ]; then
    log_error "Workspace '$WORKSPACE_NAME' does not exist"
    exit 1
fi

# Additional safety check to ensure we're not deleting root or system directories
case "$WORKSPACE_NAME" in
    "/"|"."|"..")
        log_error "Dangerous workspace name detected: $WORKSPACE_NAME"
        exit 1
        ;;
esac

# Check workspace status
state_file="$WORKSPACE_NAME/.devmorph-state"
status=""
if [ -f "$state_file" ]; then
    status=$(grep '"status"' "$state_file" 2>/dev/null | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
fi

log_info "Workspace '$WORKSPACE_NAME' status: $status"

# If workspace is running, stop it first
if [ "$status" = "running" ]; then
    log_info "Workspace is currently running. Stopping before destruction..."
    if ! stop_workspace "$WORKSPACE_NAME"; then
        log_warn "Failed to stop workspace. Proceeding with destruction anyway."
    fi
fi

# Confirm destruction unless --force is used
if [ "$FORCE" = false ]; then
    log_info "Requesting confirmation for workspace destruction"
    echo "You are about to destroy workspace '$WORKSPACE_NAME'. This cannot be undone."
    echo "All data in the workspace will be permanently deleted."
    printf "Are you sure you want to continue? (y/N): "
    read -r confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_info "Destruction cancelled by user"
        echo "Destruction cancelled."
        exit 0
    fi
else
    log_info "Force flag used, skipping confirmation"
fi

# Remove workspace directory with error handling and additional safety
# Double-check the workspace name to ensure it doesn't contain dangerous patterns
if [ -z "$WORKSPACE_NAME" ] || [ "$WORKSPACE_NAME" = "/" ] || [ "$WORKSPACE_NAME" = "." ] || [ "$WORKSPACE_NAME" = ".." ]; then
    log_error "Safety check failed, refusing to delete: $WORKSPACE_NAME"
    exit 1
fi

log_info "Destroying workspace: $WORKSPACE_NAME"
if ! rm -rf "$WORKSPACE_NAME"; then
    log_error "Failed to destroy workspace '$WORKSPACE_NAME'"
    exit 1
fi

log_info "Workspace '$WORKSPACE_NAME' destroyed successfully"
echo "Workspace '$WORKSPACE_NAME' destroyed successfully"