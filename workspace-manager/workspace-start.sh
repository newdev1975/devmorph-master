#!/bin/sh
# Workspace Start Script for DevMorph AI Studio
# Handles starting workspace containers

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

# Function to display usage
usage() {
    log_info "Displaying workspace start usage information"
    echo "Usage: $0 <workspace-name>"
    echo "  workspace-name: Name of the workspace to start (required)"
    echo "  --help: Display this help message"
    exit 0
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
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

# Check if workspace has a state file
state_file="$WORKSPACE_NAME/.devmorph-state"
if [ ! -f "$state_file" ]; then
    log_warn "Workspace '$WORKSPACE_NAME' does not have a state file, creating basic one"
    if ! mkdir -p "$WORKSPACE_NAME/.devmorph"; then
        log_error "Failed to create .devmorph directory for workspace"
        exit 1
    fi
    
    # Atomically create the state file
    tmp_state_file=$(mktemp)
    cat > "$tmp_state_file" << EOF
{
  "name": "$WORKSPACE_NAME",
  "template": "unknown",
  "mode": "dev",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "status": "configured"
}
EOF
    
    if ! mv "$tmp_state_file" "$state_file"; then
        log_error "Failed to create state file"
        exit 1
    fi
fi

# Check Docker and Docker Compose availability
log_info "Checking Docker availability..."
if ! check_docker; then
    log_error "Docker is not available"
    exit 1
fi

log_info "Checking Docker Compose availability..."
if ! check_docker_compose; then
    log_error "Docker Compose is not available"
    exit 1
fi

# Check if workspace is already running by reading state carefully
if [ -f "$state_file" ]; then
    # Use a more robust way to extract status from JSON
    current_status=$(grep '"status"' "$state_file" 2>/dev/null | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
    if [ "$current_status" = "running" ]; then
        log_warn "Workspace '$WORKSPACE_NAME' is already running"
        exit 0
    fi
else
    log_warn "State file not found, assuming workspace is not running"
    current_status="unknown"
fi

# Start the workspace
log_info "Starting workspace: $WORKSPACE_NAME"
if ! start_workspace "$WORKSPACE_NAME"; then
    log_error "Failed to start workspace '$WORKSPACE_NAME'"
    exit 1
fi

log_info "Workspace '$WORKSPACE_NAME' started successfully"
echo "Workspace '$WORKSPACE_NAME' started successfully"