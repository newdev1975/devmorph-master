#!/bin/sh
# Workspace List Script for DevMorph AI Studio
# Handles listing all workspaces

# Exit on error
set -e

# Function to display usage
usage() {
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
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            echo "Error: This command takes no arguments" >&2
            exit 1
            ;;
    esac
    shift
done

echo "Listing workspaces:"
echo "=================="

# Find all directories that contain .devmorph-state file
for dir in */; do
    if [ -d "$dir" ] && [ -f "$dir/.devmorph-state" ]; then
        dir_name=$(basename "$dir")
        mode=$(grep '"mode"' "$dir/.devmorph-state" 2>/dev/null | sed 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' 2>/dev/null || echo "unknown")
        status=$(grep '"status"' "$dir/.devmorph-state" 2>/dev/null | sed 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' 2>/dev/null || echo"unknown")
        created_at=$(grep '"created_at"' "$dir/.devmorph-state" 2>/dev/null | sed 's/.*"created_at"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' 2>/dev/null || echo "unknown")
        
        printf "%-20s %-10s %-10s %s\n" "$dir_name" "$mode" "$status" "$created_at"
    fi
done

# If no workspaces found
if ! ls */.devmorph-state >/dev/null 2>&1; then
    echo "No workspaces found."
fi