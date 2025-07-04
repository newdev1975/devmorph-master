#!/bin/sh
# Context Manager Library
# POSIX-compliant script for managing AI request contexts with proper JSON handling

set -e

# Default context directory
CONTEXT_DIR="${AI_CONTEXT_DIR:-$HOME/.local/share/devmorph/ai-context}"
SESSION_FILE=""
CURRENT_CONTEXT="default"

# Initialize context system
init_context_system() {
    # Create context directory if it doesn't exist
    if [ ! -d "$CONTEXT_DIR" ]; then
        mkdir -p "$CONTEXT_DIR"
    fi
    
    # Create default context file if it doesn't exist
    if [ ! -f "$CONTEXT_DIR/default.json" ]; then
        create_context "default"
    fi
}

# Create a new context using proper JSON
create_context() {
    context_name="$1"
    if [ -z "$context_name" ]; then
        echo "Error: Context name is required" >&2
        return 1
    fi
    
    context_file="$CONTEXT_DIR/$context_name.json"
    
    # Initialize with empty context data using proper JSON format
    cat > "$context_file" << EOF
{
  "name": "$context_name",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_used": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "workspace": "",
  "files": [],
  "conversation_history": []
}
EOF
    
    echo "Created context: $context_name"
}

# Load context data
load_context() {
    context_name="$1"
    if [ -z "$context_name" ]; then
        context_name="default"
    fi
    
    context_file="$CONTEXT_DIR/$context_name.json"
    if [ ! -f "$context_file" ]; then
        echo "Context '$context_name' does not exist, creating it..." >&2
        create_context "$context_name"
    fi
    
    CURRENT_CONTEXT="$context_name"
    SESSION_FILE="$context_file"
    
    # Update last used timestamp
    update_context_timestamp
    
    echo "Loaded context: $context_name"
}

# Update the last used timestamp
update_context_timestamp() {
    if [ -f "$SESSION_FILE" ]; then
        # Check if jq is available for proper JSON manipulation
        if command -v jq >/dev/null 2>&1; then
            # Use jq to update the last_used field
            jq --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.last_used = $now' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
        else
            # Fallback implementation using sed for systems without jq
            # This is more careful than the simplified version
            temp_file=$(mktemp)
            sed "s/\"last_used\": \".*\"}\"/\"last_used\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}/" "$SESSION_FILE" > "$temp_file" 2>/dev/null || {
                # If the simple approach fails, write an error
                echo "Error: Could not update context timestamp - jq not available and sed update failed" >&2
                rm -f "$temp_file"
                return 1
            }
            mv "$temp_file" "$SESSION_FILE"
        fi
    fi
}

# Add file to context with proper JSON handling
add_file_to_context() {
    file_path="$1"
    if [ -z "$file_path" ]; then
        echo "Error: File path is required" >&2
        return 1
    fi
    
    if [ ! -f "$file_path" ]; then
        echo "Error: File does not exist: $file_path" >&2
        return 1
    fi
    
    # Get absolute path
    if command -v realpath >/dev/null 2>&1; then
        abs_path=$(realpath "$file_path")
    else
        # Fallback for systems without realpath
        if [ -d "$file_path" ]; then
            abs_path=$(cd "$file_path" && pwd)
        else
            abs_path=$(cd "$(dirname "$file_path")" && pwd)/$(basename "$file_path")
        fi
    fi
    
    # Check if jq is available
    if command -v jq >/dev/null 2>&1; then
        # Check if file is already in context
        file_exists=$(jq -r ".files | map(select(. == \"$abs_path\")) | length" "$SESSION_FILE")
        if [ "$file_exists" -gt 0 ]; then
            echo "File already in context: $abs_path"
            return 0
        fi
        
        # Add the file to the files array using jq
        jq --arg new_file "$abs_path" '.files |= (. + [$new_file])' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
        echo "Added file to context: $abs_path"
    else
        # Fallback implementation for systems without jq
        # Check if file already exists in context
        if grep -q "$abs_path" "$SESSION_FILE" 2>/dev/null; then
            echo "File already in context: $abs_path"
            return 0
        fi
        
        # Find the files array and add the new file
        temp_file=$(mktemp)
        sed "/\"files\": \[/,/\]/ s/\(\[.*\)/\1\"$abs_path\", /" "$SESSION_FILE" > "$temp_file" 2>/dev/null || {
            # If this approach fails, we'll need a different method
            echo "Error: Could not add file to context - jq not available and sed update failed" >&2
            rm -f "$temp_file"
            return 1
        }
        
        mv "$temp_file" "$SESSION_FILE"
        echo "Added file to context: $abs_path"
    fi
}

# Remove file from context with proper JSON handling
remove_file_from_context() {
    file_path="$1"
    if [ -z "$file_path" ]; then
        echo "Error: File path is required" >&2
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        # Remove the file from the files array using jq
        jq --arg file_to_remove "$file_path" '.files |= map(select(. != $file_to_remove))' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
        echo "Removed file from context: $file_path"
    else
        # Fallback implementation for systems without jq
        # This is a basic implementation - in production, we'd want a more robust approach
        temp_file=$(mktemp)
        sed "s/\"$file_path\", *//g; s/, */ /g; s/  */ /g" "$SESSION_FILE" > "$temp_file" 2>/dev/null || {
            echo "Error: Could not remove file from context - jq not available and sed update failed" >&2
            rm -f "$temp_file"
            return 1
        }
        mv "$temp_file" "$SESSION_FILE"
        echo "Removed file from context: $file_path"
    fi
}

# Set the workspace for the context
set_context_workspace() {
    workspace_path="$1"
    if [ -z "$workspace_path" ]; then
        echo "Error: Workspace path is required" >&2
        return 1
    fi
    
    if [ ! -d "$workspace_path" ]; then
        echo "Error: Workspace directory does not exist: $workspace_path" >&2
        return 1
    fi
    
    # Get absolute path
    if command -v realpath >/dev/null 2>&1; then
        abs_path=$(realpath "$workspace_path")
    else
        abs_path=$(cd "$workspace_path" && pwd)
    fi
    
    # Update the workspace field in the context
    if command -v jq >/dev/null 2>&1; then
        jq --arg workspace "$abs_path" '.workspace = $workspace' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
    else
        # Fallback implementation for systems without jq
        temp_file=$(mktemp)
        sed "s/\"workspace\": \".*\"/\"workspace\": \"$abs_path\"/" "$SESSION_FILE" > "$temp_file" 2>/dev/null || {
            echo "Error: Could not set workspace - jq not available and sed update failed" >&2
            rm -f "$temp_file"
            return 1
        }
        mv "$temp_file" "$SESSION_FILE"
    fi
    
    echo "Set workspace for context '$CURRENT_CONTEXT': $abs_path"
}

# Add conversation to context with proper JSON handling
add_conversation_to_context() {
    role="$1"
    content="$2"
    timestamp="${3:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
    
    if [ -z "$role" ] || [ -z "$content" ]; then
        echo "Error: Role and content are required" >&2
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        # Create the conversation entry and add it to the history using jq
        jq -n --arg role "$role" --arg content "$content" --arg timestamp "$timestamp" '{"role": $role, "content": $content, "timestamp": $timestamp}' > /tmp/conversation_entry.json
        
        # Append the new entry to the conversation history
        jq --slurpfile new_entry /tmp/conversation_entry.json '.conversation_history |= . + $new_entry' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
        
        # Clean up temporary file
        rm -f /tmp/conversation_entry.json
        
        echo "Added conversation to context ($role)"
    else
        # Fallback implementation for systems without jq
        # Since this is complex without a proper JSON parser, we'll return an error
        echo "Error: Cannot add conversation to context - jq is required for complex JSON operations" >&2
        return 1
    fi
}

# List all contexts
list_contexts() {
    if [ -d "$CONTEXT_DIR" ]; then
        echo "Available contexts:"
        find "$CONTEXT_DIR" -name "*.json" -exec basename {} .json \; | while read -r context; do
            if [ "$context" = "$CURRENT_CONTEXT" ]; then
                echo "  * $context (current)"
            else
                echo "  - $context"
            fi
        done
    else
        echo "No contexts found"
    fi
}

# Get the current context data
get_context_data() {
    if [ -f "$SESSION_FILE" ]; then
        cat "$SESSION_FILE"
    else
        echo "{}"
    fi
}

# Get files in current context
get_context_files() {
    if [ -f "$SESSION_FILE" ]; then
        if command -v jq >/dev/null 2>&1; then
            jq -r '.files[]' "$SESSION_FILE" 2>/dev/null || echo ""
        else
            echo "Error: jq required to retrieve context files" >&2
            return 1
        fi
    else
        echo ""
    fi
}

# Get conversation history from context
get_conversation_history() {
    if [ -f "$SESSION_FILE" ]; then
        if command -v jq >/dev/null 2>&1; then
            jq -r '.conversation_history[] | "\(.timestamp) [\(.role)]: \(.content)"' "$SESSION_FILE" 2>/dev/null || echo ""
        else
            echo "Error: jq required to retrieve conversation history" >&2
            return 1
        fi
    else
        echo ""
    fi
}

# Initialize context system on script load
init_context_system