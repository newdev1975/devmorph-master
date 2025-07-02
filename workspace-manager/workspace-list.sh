#!/bin/sh
# Workspace List Script for DevMorph AI Studio
# Handles listing all workspaces

# Exit on error
set -e

# Source the required libraries with error handling
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"

# Check if library files exist before sourcing
if [ ! -f "$LIB_DIR/logger.sh" ]; then
    echo "ERROR [$(basename "$0")] Logger library not found: $LIB_DIR/logger.sh" >&2
    exit 1
fi

if [ ! -f "$LIB_DIR/helpers.sh" ]; then
    echo "ERROR [$(basename "$0")] Helpers library not found: $LIB_DIR/helpers.sh" >&2
    exit 1
fi

# Source all libraries
. "$LIB_DIR/logger.sh"
. "$LIB_DIR/helpers.sh"

# Initialize logging
initialize_logger

# Function to display usage
usage() {
    log_info "Displaying workspace list usage information"
    echo "Usage: $0"
    echo "  List all workspaces in the current directory"
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
            exit 1
            ;;
        *)
            log_error "This command takes no arguments"
            exit 1
            ;;
    esac
    shift
done

log_info "Listing all workspaces"

echo "Listing workspaces:"
echo "=================="
printf "%-20s %-15s %-15s %s\n" "NAME" "MODE" "STATUS" "CREATED_AT"
echo "--------------------------------------------------------------------------------"

# Find all directories that contain .devmorph-state file with better error handling
workspace_count=0
for dir in */; do
    # Skip if no directories match the pattern
    [ ! -e "$dir" ] && continue
    
    # Ensure we're dealing with a directory
    if [ -d "$dir" ]; then
        # Normalize the directory name by removing trailing slash
        dir_name=$(basename "${dir%/}")
        
        state_file="$dir/.devmorph-state"
        if [ -f "$state_file" ]; then
            # Use more robust method to extract JSON values
            mode=$(grep '"mode"' "$state_file" 2>/dev/null | sed -n 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
            if [ -z "$mode" ]; then
                mode="unknown"
            fi
            
            status=$(grep '"status"' "$state_file" 2>/dev/null | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
            if [ -z "$status" ]; then
                status="unknown"
            fi
            
            created_at=$(grep '"created_at"' "$state_file" 2>/dev/null | sed -n 's/.*"created_at"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
            if [ -z "$created_at" ]; then
                created_at="unknown"
            fi
            
            printf "%-20s %-15s %-15s %s\n" "$dir_name" "$mode" "$status" "$created_at"
            workspace_count=$((workspace_count + 1))
        fi
    fi
done

# If no workspaces found
if [ $workspace_count -eq 0 ]; then
    echo "No workspaces found."
    log_info "No workspaces found in current directory"
else
    log_info "Found $workspace_count workspace(s)"
fi