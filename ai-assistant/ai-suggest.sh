#!/bin/sh
# AI Suggest Assistant CLI Command
# POSIX-compliant script for AI-based suggestions and recommendations

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
SUGGESTION_TYPE="general"

# Function to display help
show_help() {
    cat << EOF
AI Suggest Assistant

Usage: $0 [OPTIONS] <prompt>

OPTIONS:
    -c, --context NAME     Use specific context (default: default)
    -w, --workspace PATH   Set workspace directory
    -m, --model TYPE       Model type: auto, local, cloud (default: auto)
    -t, --type TYPE        Suggestion type: general, code, docs, tests, refactoring (default: general)
    -h, --help            Show this help message

EXAMPLES:
    $0 "suggest improvements for this function"
    $0 -t refactoring -w ./src "recommend code structure improvements"
    $0 --model cloud --context refactor-project "suggest architectural changes"

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
        -t|--type)
            SUGGESTION_TYPE="$2"
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

# Function to select model based on user preference and suggestion type
select_model_for_suggestions() {
    case "$MODEL_TYPE" in
        "local")
            select_best_model
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                echo "Warning: Local models not available/suitable for current hardware" >&2
                echo "Falling back to cloud models..."
                SELECTED_MODEL_PROVIDER="qwen-code"  # Good for suggestions
            fi
            ;;
        "cloud")
            SELECTED_MODEL_TYPE="cloud"
            SELECTED_MODEL_PROVIDER="qwen-code"  # Good for suggestions
            ;;
        "auto"|*)
            # Auto-select based on hardware and availability
            select_best_model
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                SELECTED_MODEL_PROVIDER="qwen-code"  # Good for suggestions
            fi
            ;;
    esac
}

# Function to run suggestions
run_suggestions() {
    prompt="$1"
    
    # Load the specified context
    load_context "$CONTEXT_NAME"
    
    # If workspace is provided, set it in the context
    if [ -n "$WORKSPACE_PATH" ] && [ -d "$WORKSPACE_PATH" ]; then
        set_context_workspace "$WORKSPACE_PATH"
    fi
    
    # Start a new session or use existing one
    if ! has_active_session; then
        create_session "suggest-$(date +%Y%m%d_%H%M%S)"
        load_session "$(get_current_session_id)"
    fi
    
    # Update session metadata
    update_session_metadata "model_type" "$SELECTED_MODEL_TYPE"
    update_session_metadata "model_provider" "$SELECTED_MODEL_PROVIDER"
    update_session_metadata "context" "$CONTEXT_NAME"
    
    # Enhance prompt based on suggestion type
    case "$SUGGESTION_TYPE" in
        "code")
            enhanced_prompt="Suggest code improvements for: $prompt. Focus on best practices, efficiency, readability, and maintainability."
            ;;
        "docs")
            enhanced_prompt="Suggest documentation improvements for: $prompt. Focus on clarity, completeness, and developer experience."
            ;;
        "tests")
            enhanced_prompt="Suggest testing improvements for: $prompt. Recommend test cases, testing strategies, and coverage improvements."
            ;;
        "refactoring")
            enhanced_prompt="Suggest refactoring options for: $prompt. Focus on code structure, design patterns, and maintainability."
            ;;
        *)
            enhanced_prompt="Provide suggestions and recommendations for: $prompt. Focus on best practices, improvements, and optimization opportunities."
            ;;
    esac
    
    # Add files from context if they exist
    context_files=$(get_context_files 2>/dev/null) || true
    if [ -n "$context_files" ]; then
        enhanced_prompt="$enhanced_prompt. Relevant files in context: $context_files"
    fi
    
    # Select the appropriate model
    select_model_for_suggestions
    
    # Execute the request based on model type
    case "$SELECTED_MODEL_TYPE" in
        "local")
            result=$(run_local_ai "text" "$enhanced_prompt")
            ;;
        "cloud")
            result=$(run_cloud_ai "text" "$enhanced_prompt")
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
        echo "Error: Failed to get suggestions from AI model" >&2
        return 1
    fi
}

# Main execution
run_suggestions "$PROMPT"