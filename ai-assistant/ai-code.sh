#!/bin/sh
# AI Code Assistant CLI Command
# POSIX-compliant script for AI-based code assistance

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
WORKSPACE_PATH=""
TEMPERATURE=0.7
MAX_TOKENS=2048

# Function to display help
show_help() {
    cat << EOF
AI Code Assistant

Usage: $0 [OPTIONS] <prompt>

OPTIONS:
    -c, --context NAME     Use specific context (default: default)
    -w, --workspace PATH   Set workspace directory
    -m, --model TYPE       Model type: auto, local, cloud (default: auto)
    -t, --temperature N    Set temperature (0.0-1.0, default: 0.7)
    -k, --tokens N         Max tokens to generate (default: 2048)
    -h, --help            Show this help message

EXAMPLES:
    $0 "optimize this database query"
    $0 -c myproject -w ./src "refactor this function"
    $0 --model cloud "write unit tests for UserAuth module"

EOF
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -c|--context)
            CONTEXT_NAME="$2"
            shift 2
            ;;
        -w|--workspace)
            WORKSPACE_PATH="$2"
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
        -k|--tokens|--max-tokens)
            MAX_TOKENS="$2"
            shift 2
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

# The remaining argument is the prompt
PROMPT="$1"

if [ -z "$PROMPT" ]; then
    echo "Error: No prompt provided" >&2
    show_help
    exit 1
fi

# Function to select model based on user preference and availability
select_model_for_code_assist() {
    case "$MODEL_TYPE" in
        "local")
            select_best_model
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                echo "Warning: Local models not available/suitable for current hardware" >&2
                echo "Falling back to cloud models..."
                SELECTED_MODEL_TYPE="cloud"
                SELECTED_MODEL_PROVIDER="qwen-code"  # Default to qwen for code
            fi
            ;;
        "cloud")
            SELECTED_MODEL_TYPE="cloud"
            SELECTED_MODEL_PROVIDER="qwen-code"  # Default to qwen for code
            ;;
        "auto"|*)
            # Auto-select based on hardware and availability
            select_best_model
            # If hardware isn't suitable for local models, default to cloud for code
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                SELECTED_MODEL_PROVIDER="qwen-code"  # Default to qwen for code
            elif [ "$SELECTED_MODEL_PROVIDER" != "llama-cpp" ]; then
                # If we have local hardware but not llama, default to llama for code
                SELECTED_MODEL_PROVIDER="llama-cpp"
            fi
            ;;
    esac
}

# Function to run code assistance
run_code_assistance() {
    prompt="$1"
    
    # Load the specified context
    load_context "$CONTEXT_NAME"
    
    # If workspace is provided, set it in the context
    if [ -n "$WORKSPACE_PATH" ] && [ -d "$WORKSPACE_PATH" ]; then
        set_context_workspace "$WORKSPACE_PATH"
    fi
    
    # Start a new session or use existing one
    if ! has_active_session; then
        create_session "code-assist-$(date +%Y%m%d_%H%M%S)"
        load_session "$(get_current_session_id)"
    fi
    
    # Update session metadata
    update_session_metadata "model_type" "$SELECTED_MODEL_TYPE"
    update_session_metadata "model_provider" "$SELECTED_MODEL_PROVIDER"
    update_session_metadata "context" "$CONTEXT_NAME"
    
    # Enhance prompt with context information
    enhanced_prompt="As an expert software developer, please help with the following: $prompt"
    if [ -n "$WORKSPACE_PATH" ]; then
        enhanced_prompt="$enhanced_prompt. The relevant workspace context is: $WORKSPACE_PATH"
    fi
    
    # Add files from context if they exist
    context_files=$(get_context_files 2>/dev/null) || true
    if [ -n "$context_files" ]; then
        enhanced_prompt="$enhanced_prompt. Relevant files: $context_files"
    fi
    
    # Select the appropriate model
    select_model_for_code_assist
    
    # Execute the request based on model type
    case "$SELECTED_MODEL_TYPE" in
        "local")
            # Add code-specific instructions for local models
            enhanced_prompt="### Instruction: $enhanced_prompt

Provide accurate, efficient, and well-documented code solutions. Use proper indentation and follow best practices."
            result=$(run_local_ai "code" "$enhanced_prompt")
            ;;
        "cloud")
            result=$(run_cloud_ai "code" "$enhanced_prompt")
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
        # Estimate token usage based on response length
        response_length=$(echo "$result" | wc -c)
        estimated_tokens=$(expr $response_length / 4)  # Rough estimate: 1 token ~ 4 chars
        if [ $estimated_tokens -lt 1 ]; then
            estimated_tokens=1
        fi
        update_tokens_used $estimated_tokens
        
        # Add to context history
        add_conversation_to_context "user" "$enhanced_prompt"
        
        return 0
    else
        echo "Error: Failed to get response from AI model" >&2
        return 1
    fi
}

# Main execution
run_code_assistance "$PROMPT"