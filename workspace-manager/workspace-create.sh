#!/bin/sh
# Workspace Creation Script for DevMorph AI Studio
# Handles the creation of new workspaces from templates

# Exit on error
set -e

# Source the required libraries with error handling
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"

# Check if library files exist before sourcing
if [ ! -f "$LIB_DIR/template-renderer.sh" ]; then
    echo "ERROR [$(basename "$0")] Template renderer library not found: $LIB_DIR/template-renderer.sh" >&2
    exit 1
fi

if [ ! -f "$LIB_DIR/config-manager.sh" ]; then
    echo "ERROR [$(basename "$0")] Config manager library not found: $LIB_DIR/config-manager.sh" >&2
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
. "$LIB_DIR/template-renderer.sh"
. "$LIB_DIR/config-manager.sh"
. "$LIB_DIR/validator.sh"
. "$LIB_DIR/logger.sh"
. "$LIB_DIR/helpers.sh"

# Initialize logging
initialize_logger

# Default values
WORKSPACE_NAME=""
TEMPLATE_NAME=""
MODE="dev"

# Function to display usage
usage() {
    log_info "Displaying workspace create usage information"
    echo "Usage: $0 --name <workspace-name> --template <template-name> [--mode <mode>]"
    echo "  --name: Name of the workspace to create (required)"
    echo "  --template: Name of the template to use (required)"
    echo "  --mode: Mode for the workspace (dev, prod, staging, test, design, mix) - default: dev"
    echo "  --help: Display this help message"
    exit 0
}

# Parse command line arguments with enhanced validation
while [ $# -gt 0 ]; do
    case "$1" in
        --name)
            if [ -n "$2" ]; then
                WORKSPACE_NAME="$2"
                shift 2
            else
                log_error "--name requires an argument"
                usage
            fi
            ;;
        --template)
            if [ -n "$2" ]; then
                TEMPLATE_NAME="$2"
                shift 2
            else
                log_error "--template requires an argument"
                usage
            fi
            ;;
        --mode)
            if [ -n "$2" ]; then
                MODE="$2"
                shift 2
            else
                log_error "--mode requires an argument"
                usage
            fi
            ;;
        --help|-h)
            usage
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            log_error "Unexpected argument: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [ -z "$WORKSPACE_NAME" ] || [ -z "$TEMPLATE_NAME" ]; then
    log_error "Both --name and --template are required"
    usage
fi

# Validate workspace name with additional security checks
if ! validate_workspace_name "$WORKSPACE_NAME"; then
    log_error "Invalid workspace name: $WORKSPACE_NAME"
    exit 1
fi

# Additional security check to prevent directory traversal
case "$WORKSPACE_NAME" in
    */*|*../*|*/*..|*\.\./*)
        log_error "Workspace name contains invalid path characters"
        exit 1
        ;;
esac

# Validate template name
if ! validate_template_name "$TEMPLATE_NAME"; then
    log_error "Invalid template name: $TEMPLATE_NAME"
    exit 1
fi

# Additional security check for template name
case "$TEMPLATE_NAME" in
    */*|*../*|*/*..|*\.\./*)
        log_error "Template name contains invalid path characters"
        exit 1
        ;;
esac

# Check if workspace already exists
if [ -d "$WORKSPACE_NAME" ]; then
    log_error "Workspace '$WORKSPACE_NAME' already exists"
    exit 1
fi

# Define template and mode paths with security checks
TEMPLATE_PATH="../templates/$TEMPLATE_NAME"
MODE_PATH="$SCRIPT_DIR/modes/$MODE"

# Validate template exists and is a directory
if [ ! -d "$TEMPLATE_PATH" ]; then
    log_error "Template '$TEMPLATE_NAME' does not exist at $TEMPLATE_PATH"
    exit 1
fi

# Validate mode exists and is a directory
if [ ! -d "$MODE_PATH" ]; then
    log_error "Mode '$MODE' does not exist at $MODE_PATH"
    exit 1
fi

# Validate that mode is one of the allowed values
if ! echo "dev prod staging test design mix" | grep -qw "$MODE"; then
    log_error "Invalid mode: '$MODE'. Must be one of: dev, prod, staging, test, design, mix"
    exit 1
fi

# Create workspace directory with error handling
log_info "Creating workspace '$WORKSPACE_NAME' from template '$TEMPLATE_NAME' with mode '$MODE'..."
if ! mkdir -p "$WORKSPACE_NAME"; then
    log_error "Failed to create directory: $WORKSPACE_NAME"
    exit 1
fi

# Copy template files to workspace with enhanced safety
if [ -d "$TEMPLATE_PATH" ]; then
    # Check if template path has contents
    if [ "$(ls -A "$TEMPLATE_PATH" 2>/dev/null)" ]; then
        # Use safer copy method to prevent path traversal
        if ! (cd "$TEMPLATE_PATH" && tar cf - .) | (cd "$WORKSPACE_NAME" && tar xf -); then
            log_error "Failed to copy template files from '$TEMPLATE_PATH'"
            exit 1
        fi
    fi
fi

# Copy mode-specific configuration to workspace with enhanced safety
if [ -d "$MODE_PATH" ]; then
    # Check if mode path has contents
    if [ "$(ls -A "$MODE_PATH" 2>/dev/null)" ]; then
        # Use safer copy method to prevent path traversal
        if ! (cd "$MODE_PATH" && tar cf - .) | (cd "$WORKSPACE_NAME" && tar xf -); then
            log_error "Failed to copy mode files from '$MODE_PATH'"
            exit 1
        fi
    fi
fi

# Initialize workspace configuration using config manager
log_info "Initializing configuration for workspace '$WORKSPACE_NAME'..."
if ! initialize_workspace_config "$WORKSPACE_NAME" "$WORKSPACE_NAME" "$TEMPLATE_NAME" "$MODE"; then
    log_error "Failed to initialize workspace configuration"
    exit 1
fi

log_info "Workspace '$WORKSPACE_NAME' created successfully!"
echo "Workspace '$WORKSPACE_NAME' created successfully!"