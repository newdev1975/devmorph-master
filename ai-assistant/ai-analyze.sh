#!/bin/sh
# AI Analysis Assistant CLI Command
# POSIX-compliant script for AI-based project analysis

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
ANALYSIS_TYPE="general"

# Function to display help
show_help() {
    cat << EOF
AI Analysis Assistant

Usage: $0 [OPTIONS] <prompt>

OPTIONS:
    -c, --context NAME     Use specific context (default: default)
    -w, --workspace PATH   Set workspace directory
    -m, --model TYPE       Model type: auto, local, cloud (default: auto)
    -t, --type TYPE        Analysis type: general, security, performance, architecture (default: general)
    -h, --help            Show this help message

EXAMPLES:
    $0 "analyze this codebase for potential security issues"
    $0 -t security -w ./my-project "review authentication system"
    $0 --model cloud --context security-review "perform threat modeling"

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
            ANALYSIS_TYPE="$2"
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

# Function to select model based on user preference and analysis type
select_model_for_analysis() {
    case "$MODEL_TYPE" in
        "local")
            select_best_model
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                echo "Warning: Local models not available/suitable for current hardware" >&2
                echo "Falling back to cloud models..."
                SELECTED_MODEL_PROVIDER="qwen-code"  # Good for analysis tasks
            fi
            ;;
        "cloud")
            SELECTED_MODEL_TYPE="cloud"
            SELECTED_MODEL_PROVIDER="qwen-code"  # Default good for analysis
            ;;
        "auto"|*)
            # Auto-select based on hardware and availability
            select_best_model
            # For analysis, prefer models with more reasoning capability
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                SELECTED_MODEL_PROVIDER="qwen-code"  # Good for analysis
            fi
            ;;
    esac
}

# Function to run analysis
run_analysis() {
    prompt="$1"
    
    # Load the specified context
    load_context "$CONTEXT_NAME"
    
    # If workspace is provided, set it in the context
    if [ -n "$WORKSPACE_PATH" ] && [ -d "$WORKSPACE_PATH" ]; then
        set_context_workspace "$WORKSPACE_PATH"
    fi
    
    # Start a new session or use existing one
    if ! has_active_session; then
        create_session "analysis-$(date +%Y%m%d_%H%M%S)"
        load_session "$(get_current_session_id)"
    fi
    
    # Update session metadata
    update_session_metadata "model_type" "$SELECTED_MODEL_TYPE"
    update_session_metadata "model_provider" "$SELECTED_MODEL_PROVIDER"
    update_session_metadata "context" "$CONTEXT_NAME"
    
    # Enhance prompt based on analysis type
    case "$ANALYSIS_TYPE" in
        "security")
            enhanced_prompt="Perform a detailed security analysis of: $prompt. Focus on potential vulnerabilities, security best practices, and mitigation strategies."
            ;;
        "performance")
            enhanced_prompt="Analyze the performance aspects of: $prompt. Identify bottlenecks, optimization opportunities, and performance best practices."
            ;;
        "architecture")
            enhanced_prompt="Review the system architecture described in: $prompt. Assess design patterns, scalability, maintainability, and architectural best practices."
            ;;
        *)
            enhanced_prompt="Analyze the following: $prompt. Provide detailed insights, recommendations, and best practices."
            ;;
    esac
    
    # Add files from context if they exist
    context_files=$(get_context_files 2>/dev/null) || true
    if [ -n "$context_files" ]; then
        enhanced_prompt="$enhanced_prompt. Relevant files in context: $context_files"
    fi
    
    # Select the appropriate model
    select_model_for_analysis
    
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
        echo "Error: Failed to get analysis from AI model" >&2
        return 1
    fi
}

# Main execution
run_analysis "$PROMPT"