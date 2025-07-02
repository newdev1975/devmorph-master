#!/bin/sh
# Workspace Mode Script for DevMorph AI Studio
# Handles workspace mode management (set/show)

# Exit on error
set -e

# Source the required libraries with error handling
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"

# Check if library files exist before sourcing
if [ ! -f "$LIB_DIR/mode-handler.sh" ]; then
    echo "ERROR [$(basename "$0")] Mode handler library not found: $LIB_DIR/mode-handler.sh" >&2
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
. "$LIB_DIR/mode-handler.sh"
. "$LIB_DIR/validator.sh"
. "$LIB_DIR/logger.sh"
. "$LIB_DIR/helpers.sh"

# Initialize logging
initialize_logger

# Default values
SUBCOMMAND=""
WORKSPACE_NAME=""
NEW_MODE=""

# Function to display usage
usage() {
    log_info "Displaying workspace mode usage information"
    echo "Usage: $0 (set|show) <workspace-name> [--mode <mode>]"
    echo "  set: Set mode for a workspace"
    echo "  show: Show current mode of a workspace"
    echo "  workspace-name: Name of the workspace"
    echo "  --mode: Mode to set (required for 'set' command)"
    echo "  --help: Display this help message"
    exit 0
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
    log_error "Invalid subcommand '$SUBCOMMAND'. Use 'set' or 'show'."
    exit 1
fi

# Parse remaining arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --mode)
            if [ -n "$2" ]; then
                NEW_MODE="$2"
                shift 2
            else
                log_error "--mode requires an argument"
                exit 1
            fi
            ;;
        --help|-h)
            usage
            ;;
        -*)
            log_error "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$WORKSPACE_NAME" ]; then
                WORKSPACE_NAME="$1"
            else
                log_error "Too many arguments"
                exit 1
            fi
            ;;
    esac
    shift
done

# Validate required parameters
if [ -z "$WORKSPACE_NAME" ]; then
    log_error "Workspace name is required"
    exit 1
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

# Execute based on subcommand
case "$SUBCOMMAND" in
    "set")
        # Validate mode parameter
        if [ -z "$NEW_MODE" ]; then
            log_error "--mode is required for 'set' command"
            exit 1
        fi

        # Validate that the mode is one of the allowed modes
        if ! validate_mode "$NEW_MODE"; then
            available_modes=$(get_available_modes | tr '\n' ' ')
            log_error "Invalid mode '$NEW_MODE'. Available modes: $available_modes"
            exit 1
        fi

        log_info "Setting mode '$NEW_MODE' for workspace '$WORKSPACE_NAME'"
        
        # Set the new mode
        if ! switch_workspace_mode "$WORKSPACE_NAME" "$NEW_MODE"; then
            log_error "Failed to set mode for workspace '$WORKSPACE_NAME'"
            exit 1
        fi
        
        echo "Mode set successfully for workspace '$WORKSPACE_NAME'"
        ;;
    "show")
        # Show current mode
        log_info "Retrieving mode for workspace '$WORKSPACE_NAME'"
        current_mode=$(get_workspace_mode "$WORKSPACE_NAME")
        
        if [ "$current_mode" = "unknown" ]; then
            log_warn "Could not determine mode for workspace '$WORKSPACE_NAME'"
        fi
        
        echo "Workspace '$WORKSPACE_NAME' is in mode: $current_mode"
        ;;
esac