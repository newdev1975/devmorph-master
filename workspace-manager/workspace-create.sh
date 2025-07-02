#!/bin/sh
# Workspace Creation Script for DevMorph AI Studio
# Handles the creation of new workspaces from templates

# Exit on error
set -e

# Source the required libraries
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"
. "$LIB_DIR/template-renderer.sh"

# Default values
WORKSPACE_NAME=""
TEMPLATE_NAME=""
MODE="dev"

# Function to display usage
usage() {
    echo "Usage: $0 --name <workspace-name> --template <template-name> [--mode <mode>]"
    echo "  --name: Name of the workspace to create (required)"
    echo "  --template: Name of the template to use (required)"
    echo "  --mode: Mode for the workspace (dev, prod, staging, test, design, mix) - default: dev"
    echo "  --help: Display this help message"
    exit 0
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --name)
            WORKSPACE_NAME="$2"
            shift 2
            ;;
        --template)
            TEMPLATE_NAME="$2"
            shift 2
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

# Validate required parameters
if [ -z "$WORKSPACE_NAME" ] || [ -z "$TEMPLATE_NAME" ]; then
    echo "Error: Both --name and --template are required" >&2
    usage
fi

# Validate workspace name
if ! validate_workspace_name "$WORKSPACE_NAME"; then
    exit 1
fi

# Check if workspace already exists
if workspace_exists "$WORKSPACE_NAME"; then
    echo "Error: Workspace '$WORKSPACE_NAME' already exists" >&2
    exit 1
fi

# Define template and mode paths
TEMPLATE_PATH="../templates/$TEMPLATE_NAME"
MODE_PATH="$SCRIPT_DIR/modes/$MODE"

# Validate template exists
if [ ! -d "$TEMPLATE_PATH" ]; then
    echo "Error: Template '$TEMPLATE_NAME' does not exist at $TEMPLATE_PATH" >&2
    exit 1
fi

# Validate mode exists
if [ ! -d "$MODE_PATH" ]; then
    echo "Error: Mode '$MODE' does not exist" >&2
    exit 1
fi

# Create workspace directory
echo "Creating workspace '$WORKSPACE_NAME' from template '$TEMPLATE_NAME' with mode '$MODE'..."
mkdir -p "$WORKSPACE_NAME"

# Copy template files to workspace
cp -r "$TEMPLATE_PATH"/* "$WORKSPACE_NAME/" 2>/dev/null || true

# Copy mode-specific configuration to workspace
cp -r "$MODE_PATH"/* "$WORKSPACE_NAME/" 2>/dev/null || true  # Continue if mode directory is empty

# Create workspace state file
cat > "$WORKSPACE_NAME/.devmorph-state" << EOF
{
    "name": "$WORKSPACE_NAME",
    "template": "$TEMPLATE_NAME",
    "mode": "$MODE",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "status": "created"
}
EOF

echo "Workspace '$WORKSPACE_NAME' created successfully!"