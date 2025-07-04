#!/bin/sh
# AI Chat Assistant CLI Command
# POSIX-compliant script for interactive AI chat

set -e

# Load required libraries
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/lib/context-manager.sh"
. "$SCRIPT_DIR/lib/session-manager.sh"
. "$SCRIPT_DIR/lib/model-selector.sh"
. "$SCRIPT_DIR/local-ai.sh"
. "$SCRIPT_DIR/cloud-ai.sh"
. "$SCRIPT_DIR/model-health-check.sh"

# Default values
MODEL_TYPE="auto"  # auto, local, cloud
CONTEXT_NAME="default"
CHAT_HISTORY_LINES=50
TEMPERATURE=0.7

# Function to display help
show_help() {
    cat << EOF
AI Chat Assistant

Usage: $0 [OPTIONS] [prompt]

OPTIONS:
    -c, --context NAME     Use specific context (default: default)
    -l, --lines N         Number of history lines to include (default: 50)
    -m, --model TYPE      Model type: auto, local, cloud (default: auto)
    -t, --temperature N   Set temperature (0.0-1.0, default: 0.7)
    --clear               Clear the current chat context
    -h, --help           Show this help message

If no prompt is provided, starts an interactive chat session.

EXAMPLES:
    $0 "What's the weather like?"
    $0 --context personal "How do I cook pasta?"
    $0 --model cloud      # Start interactive chat session

EOF
}

# Parse command line arguments
CLEAR_CHAT="false"
INTERACTIVE_MODE="false"

while [ $# -gt 0 ]; do
    case "$1" in
        -c|--context)
            CONTEXT_NAME="$2"
            shift 2
            ;;
        -l|--lines)
            CHAT_HISTORY_LINES="$2"
            shift 2
            ;;
        -m|--model)
            MODEL_TYPE="$2"
            shift 2
            ;;
        -t|--temperature)
            TEMPERATURE="$2"
            shift 2
            ;;
        --clear)
            CLEAR_CHAT="true"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# The remaining argument is the optional prompt
PROMPT="$1"

# Function to select model for chat
select_model_for_chat() {
    case "$MODEL_TYPE" in
        "local")
            select_best_model
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                echo "Warning: Local models not available/suitable for current hardware" >&2
                echo "Falling back to cloud models..."
                SELECTED_MODEL_PROVIDER="qwen-code"
            fi
            ;;
        "cloud")
            SELECTED_MODEL_TYPE="cloud"
            SELECTED_MODEL_PROVIDER="qwen-code"  # Good general-purpose model
            ;;
        "auto"|*)
            # Auto-select based on hardware and availability
            select_best_model
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                SELECTED_MODEL_PROVIDER="qwen-code"  # Good general-purpose model
            fi
            ;;
    esac
}

# Function to get recent conversation history from context
get_recent_conversation_history() {
    # This would return the last N messages from the context's conversation history
    # For this implementation, we'll return a summary of recent conversation
    recent_history=$(get_conversation_history 2>/dev/null | tail -n "$CHAT_HISTORY_LINES") || true
    
    if [ -n "$recent_history" ]; then
        echo "Recent conversation history:"
        echo "$recent_history"
        echo ""
    fi
}

# Function to run single chat message
run_single_chat() {
    prompt="$1"
    
    # Load the specified context
    load_context "$CONTEXT_NAME"
    
    # Start a new session or use existing one
    if ! has_active_session; then
        create_session "chat-$(date +%Y%m%d_%H%M%S)"
        load_session "$(get_current_session_id)"
    fi
    
    # Update session metadata
    update_session_metadata "model_type" "$SELECTED_MODEL_TYPE"
    update_session_metadata "model_provider" "$SELECTED_MODEL_PROVIDER"
    update_session_metadata "context" "$CONTEXT_NAME"
    
    # Get conversation history to include in the prompt
    history_context=$(get_recent_conversation_history)
    
    # Build the full prompt with context
    full_prompt="$history_context$prompt"
    
    # Select the appropriate model
    select_model_for_chat
    
    # Execute the request based on model type
    case "$SELECTED_MODEL_TYPE" in
        "local")
            result=$(run_local_ai "text" "$full_prompt")
            ;;
        "cloud")
            result=$(run_cloud_ai "text" "$full_prompt")
            ;;
        *)
            echo "Error: No available models" >&2
            return 1
            ;;
    esac
    
    # Check if the request was successful
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        # Display the result
        echo "$result"
        
        # Add to conversation history
        add_conversation_to_context "assistant" "$result"
        
        # Update session stats
        increment_interaction_count
        update_tokens_used 80  # Placeholder value for chat
        
        # Add to context history
        add_conversation_to_context "user" "$prompt"
        
        return 0
    else
        echo "Error: Failed to get response from AI model" >&2
        return 1
    fi
}

# Function to start interactive chat session
start_interactive_chat() {
    # Load or create context
    load_context "$CONTEXT_NAME"
    
    # Start a new session
    session_id="chat-$(date +%Y%m%d_%H%M%S)"
    create_session "$session_id"
    load_session "$session_id"
    
    # Update session metadata
    update_session_metadata "model_type" "$SELECTED_MODEL_TYPE"
    update_session_metadata "model_provider" "$SELECTED_MODEL_PROVIDER"
    update_session_metadata "context" "$CONTEXT_NAME"
    
    # Select the appropriate model
    select_model_for_chat
    
    echo "AI Chat Assistant started (context: $CONTEXT_NAME, model: $SELECTED_MODEL_TYPE/$SELECTED_MODEL_PROVIDER)"
    echo "Type your messages below. Use 'exit', 'quit', or Ctrl+C to end the session."
    echo ""
    
    while true; do
        printf "You: "
        read -r user_input
        
        # Check for exit commands
        case "$user_input" in
            "exit"|"quit"|"bye"|"goodbye")
                echo "AI: Goodbye!"
                break
                ;;
            "")
                continue  # Skip empty input
                ;;
        esac
        
        # Get conversation history to include in the prompt
        history_context=$(get_recent_conversation_history)
        
        # Build the full prompt with context
        full_prompt="$history_context$user_input"
        
        # Execute the request based on model type
        case "$SELECTED_MODEL_TYPE" in
            "local")
                result=$(run_local_ai "text" "$full_prompt")
                ;;
            "cloud")
                result=$(run_cloud_ai "text" "$full_prompt")
                ;;
            *)
                echo "Error: No available models" >&2
                break
                ;;
        esac
        
        # Check if the request was successful
        if [ $? -eq 0 ] && [ -n "$result" ]; then
            echo "AI: $result"
            
            # Add to conversation history
            add_conversation_to_context "assistant" "$result"
            
            # Update session stats
            increment_interaction_count
            # Estimate token usage based on response length
            response_length=$(echo "$result" | wc -c)
            estimated_tokens=$(expr $response_length / 4)  # Rough estimate: 1 token ~ 4 chars
            if [ $estimated_tokens -lt 1 ]; then
                estimated_tokens=1
            fi
            update_tokens_used $estimated_tokens
            
            # Add to context history
            add_conversation_to_context "user" "$user_input"
        else
            echo "AI: Sorry, I couldn't process that request. Please try again."
        fi
        
        echo ""
    done
}

# Main execution
# Handle clear command first
if [ "$CLEAR_CHAT" = "true" ]; then
    # Create a new context to clear the old one
    echo "Clearing chat context: $CONTEXT_NAME"
    create_context "$CONTEXT_NAME"
    load_context "$CONTEXT_NAME"
    echo "Chat context cleared."
    exit 0
fi

# Decide whether to run in interactive mode or single message mode
if [ -z "$PROMPT" ]; then
    # No prompt provided, start interactive mode
    start_interactive_chat
else
    # Prompt provided, run single message
    run_single_chat "$PROMPT"
fi