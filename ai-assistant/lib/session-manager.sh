#!/bin/sh
# Session Manager Library
# POSIX-compliant script for managing AI assistant sessions with proper JSON handling

set -e

# Default session directory
SESSION_DIR="${AI_SESSION_DIR:-$HOME/.local/share/devmorph/ai-sessions}"
CURRENT_SESSION=""
SESSION_FILE=""
SESSION_LOCK_FILE=""

# Initialize session system
init_session_system() {
    # Create session directory if it doesn't exist
    if [ ! -d "$SESSION_DIR" ]; then
        mkdir -p "$SESSION_DIR"
    fi
    
    # Set up signal handlers for clean session termination
    trap cleanup_session EXIT INT TERM
}

# Create a new session with proper JSON
create_session() {
    session_name="$1"
    if [ -z "$session_name" ]; then
        session_name="session_$(date +%Y%m%d_%H%M%S)"
    fi
    
    session_id="$session_name"
    session_file="$SESSION_DIR/${session_id}.json"
    
    # Check if session already exists
    if [ -f "$session_file" ]; then
        echo "Error: Session '$session_id' already exists" >&2
        return 1
    fi
    
    # Create session lock file to prevent concurrent access
    session_lock_file="$SESSION_DIR/${session_id}.lock"
    if [ -f "$session_lock_file" ]; then
        echo "Error: Session is locked by another process" >&2
        return 1
    fi
    
    touch "$session_lock_file"
    SESSION_LOCK_FILE="$session_lock_file"
    
    # Initialize session data with proper JSON format
    cat > "$session_file" << EOF
{
  "session_id": "$session_id",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "active",
  "model_type": "",
  "model_provider": "",
  "interaction_count": 0,
  "tokens_used": 0,
  "context": "default"
}
EOF
    
    # Set global session variables
    CURRENT_SESSION="$session_id"
    SESSION_FILE="$session_file"
    
    echo "Created session: $session_id"
    return 0
}

# Load an existing session
load_session() {
    session_id="$1"
    if [ -z "$session_id" ]; then
        echo "Error: Session ID is required" >&2
        return 1
    fi
    
    session_file="$SESSION_DIR/${session_id}.json"
    if [ ! -f "$session_file" ]; then
        echo "Error: Session '$session_id' does not exist" >&2
        return 1
    fi
    
    # Check if session is locked
    session_lock_file="$SESSION_DIR/${session_id}.lock"
    if [ -f "$session_lock_file" ]; then
        echo "Warning: Session is locked, but loading anyway" >&2
    fi
    
    # Set global session variables
    CURRENT_SESSION="$session_id"
    SESSION_FILE="$session_file"
    SESSION_LOCK_FILE="$session_lock_file"
    
    echo "Loaded session: $session_id"
    return 0
}

# Update session metadata with proper JSON handling
update_session_metadata() {
    field="$1"
    value="$2"
    
    if [ -z "$field" ] || [ -z "$value" ] || [ ! -f "$SESSION_FILE" ]; then
        return 1
    fi
    
    # Check if jq is available
    if command -v jq >/dev/null 2>&1; then
        # Create appropriate jq command based on value type
        if echo "$value" | grep -E '^[0-9]+$' >/dev/null; then
            # Value is numeric
            jq --argjson val "$value" --arg field "$field" '.[$field] = $val' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
        else
            # Value is string
            jq --arg val "$value" --arg field "$field" '.[$field] = $val' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
        fi
        
        # Also update updated_at timestamp
        jq --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.updated_at = $now' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
    else
        # Fallback implementation for systems without jq
        # Since complex JSON updates require jq, we'll error out
        echo "Error: Cannot update session metadata - jq is required for JSON operations" >&2
        return 1
    fi
    
    return 0
}

# Increment interaction count with proper JSON handling
increment_interaction_count() {
    if [ ! -f "$SESSION_FILE" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        # Increment the interaction count using jq
        jq '.interaction_count += 1' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
        
        # Update timestamp
        jq --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.updated_at = $now' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
    else
        echo "Error: Cannot increment interaction count - jq is required for JSON operations" >&2
        return 1
    fi
    
    return 0
}

# Update tokens used with proper JSON handling
update_tokens_used() {
    tokens="$1"
    if [ -z "$tokens" ] || [ ! -f "$SESSION_FILE" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        # Add tokens to the existing count using jq
        jq --argjson new_tokens "$tokens" '.tokens_used += $new_tokens' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
        
        # Update timestamp
        jq --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.updated_at = $now' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
    else
        echo "Error: Cannot update tokens used - jq is required for JSON operations" >&2
        return 1
    fi
    
    return 0
}

# End the current session with proper JSON handling
end_session() {
    if [ -z "$CURRENT_SESSION" ] || [ ! -f "$SESSION_FILE" ]; then
        echo "No active session to end" >&2
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        # Update status and timestamp using jq
        jq --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '.status = "ended" | .updated_at = $now' "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
    else
        echo "Error: Cannot end session - jq is required for JSON operations" >&2
        return 1
    fi
    
    # Remove lock file
    if [ -n "$SESSION_LOCK_FILE" ] && [ -f "$SESSION_LOCK_FILE" ]; then
        rm -f "$SESSION_LOCK_FILE"
    fi
    
    echo "Ended session: $CURRENT_SESSION"
    
    # Reset session variables
    CURRENT_SESSION=""
    SESSION_FILE=""
    SESSION_LOCK_FILE=""
    
    return 0
}

# Cleanup session on exit
cleanup_session() {
    if [ -n "$CURRENT_SESSION" ] && [ -n "$SESSION_FILE" ]; then
        # Only end the session if it's still active
        if command -v jq >/dev/null 2>&1; then
            status=$(jq -r '.status' "$SESSION_FILE" 2>/dev/null)
            if [ "$status" = "active" ]; then
                end_session
            fi
        else
            echo "Warning: Cannot check session status - jq required" >&2
        fi
    fi
    
    # Remove lock file if it exists
    if [ -n "$SESSION_LOCK_FILE" ] && [ -f "$SESSION_LOCK_FILE" ]; then
        rm -f "$SESSION_LOCK_FILE"
    fi
}

# List all sessions
list_sessions() {
    if [ -d "$SESSION_DIR" ]; then
        echo "Available sessions:"
        for session_file in "$SESSION_DIR"/*.json; do
            if [ -f "$session_file" ]; then
                session=$(basename "$session_file" .json)
                
                if command -v jq >/dev/null 2>&1; then
                    status=$(jq -r '.status' "$session_file" 2>/dev/null)
                    created_at=$(jq -r '.created_at' "$session_file" 2>/dev/null)
                else
                    echo "Warning: jq required for detailed session info" >&2
                    status="unknown"
                    created_at="unknown"
                fi
                
                if [ "$session" = "$CURRENT_SESSION" ]; then
                    echo "  * $session ($status) - $created_at [current]"
                else
                    echo "  - $session ($status) - $created_at"
                fi
            fi
        done
    else
        echo "No sessions found"
    fi
}

# Get session data
get_session_data() {
    if [ -f "$SESSION_FILE" ]; then
        cat "$SESSION_FILE"
    else
        echo "{}"
    fi
}

# Get current session ID
get_current_session_id() {
    echo "$CURRENT_SESSION"
}

# Check if we have an active session
has_active_session() {
    if [ -n "$CURRENT_SESSION" ] && [ -f "$SESSION_FILE" ]; then
        if command -v jq >/dev/null 2>&1; then
            status=$(jq -r '.status' "$SESSION_FILE" 2>/dev/null)
            if [ "$status" = "active" ]; then
                return 0
            fi
        else
            echo "Warning: Cannot check session status - jq required" >&2
        fi
    fi
    return 1
}

# Get session statistics
get_session_stats() {
    if [ -f "$SESSION_FILE" ] && command -v jq >/dev/null 2>&1; then
        jq -r '
            "Session Stats:" as $header |
            "  ID: \( .session_id )" as $id |
            "  Status: \( .status )" as $status |
            "  Model: \( .model_type )/\( .model_provider )" as $model |
            "  Interactions: \( .interaction_count )" as $interactions |
            "  Tokens Used: \( .tokens_used )" as $tokens |
            "  Context: \( .context )" as $context |
            "  Created: \( .created_at )" as $created |
            "  Updated: \( .updated_at )" as $updated |
            [$header, $id, $status, $model, $interactions, $tokens, $context, $created, $updated] | .[]
        ' "$SESSION_FILE"
    else
        echo "Session stats unavailable - jq required for JSON operations" >&2
        return 1
    fi
}

# Initialize session system on script load
init_session_system