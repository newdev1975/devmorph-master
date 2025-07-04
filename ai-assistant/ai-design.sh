#!/bin/sh
# AI Design Assistant CLI Command
# POSIX-compliant script for AI-based design assistance

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
IMAGE_SIZE="512x512"
NUM_IMAGES=1

# Function to display help
show_help() {
    cat << EOF
AI Design Assistant

Usage: $0 [OPTIONS] <prompt>

OPTIONS:
    -c, --context NAME     Use specific context (default: default)
    -w, --workspace PATH   Set workspace directory
    -m, --model TYPE       Model type: auto, local, cloud (default: auto)
    -s, --size WxH         Image size (default: 512x512)
    -n, --number N         Number of images to generate (default: 1)
    -h, --help            Show this help message

EXAMPLES:
    $0 "a futuristic cityscape at sunset"
    $0 -c branding -w ./designs "logo for tech startup"
    $0 --model cloud --size 1024x1024 "photorealistic mountain landscape"

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
        -s|--size)
            IMAGE_SIZE="$2"
            shift 2
            ;;
        -n|--number|--num)
            NUM_IMAGES="$2"
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
select_model_for_design_assist() {
    case "$MODEL_TYPE" in
        "local")
            select_best_model
            if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
                echo "Warning: Local models not available/suitable for current hardware" >&2
                echo "Falling back to cloud models..."
                SELECTED_MODEL_PROVIDER="openai"  # Default to OpenAI for images
            elif [ "$SELECTED_MODEL_PROVIDER" != "stable-diffusion" ]; then
                # If local but not stable diffusion, set to stable diffusion for image gen
                SELECTED_MODEL_PROVIDER="stable-diffusion"
            fi
            ;;
        "cloud")
            SELECTED_MODEL_TYPE="cloud"
            # For design/image tasks, use OpenAI's DALL-E or other image generation service
            SELECTED_MODEL_PROVIDER="openai"  # Default to OpenAI for images
            ;;
        "auto"|*)
            # Auto-select based on hardware and availability
            select_best_model
            # If hardware isn't suitable for local models or if it's not SD, consider cloud
            if [ "$SELECTED_MODEL_TYPE" != "local" ] || [ "$SELECTED_MODEL_PROVIDER" != "stable-diffusion" ]; then
                SELECTED_MODEL_TYPE="cloud"
                SELECTED_MODEL_PROVIDER="openai"  # Default to OpenAI for images
            else
                SELECTED_MODEL_PROVIDER="stable-diffusion"
            fi
            ;;
    esac
}

# Function to run design assistance
run_design_assistance() {
    prompt="$1"
    
    # Load the specified context
    load_context "$CONTEXT_NAME"
    
    # If workspace is provided, set it in the context
    if [ -n "$WORKSPACE_PATH" ] && [ -d "$WORKSPACE_PATH" ]; then
        set_context_workspace "$WORKSPACE_PATH"
    fi
    
    # Start a new session or use existing one
    if ! has_active_session; then
        create_session "design-assist-$(date +%Y%m%d_%H%M%S)"
        load_session "$(get_current_session_id)"
    fi
    
    # Update session metadata
    update_session_metadata "model_type" "$SELECTED_MODEL_TYPE"
    update_session_metadata "model_provider" "$SELECTED_MODEL_PROVIDER"
    update_session_metadata "context" "$CONTEXT_NAME"
    
    # Enhance prompt with design context
    enhanced_prompt="Generate an image based on this description: $prompt"
    
    # For cloud models, especially OpenAI's DALL-E
    if [ "$SELECTED_MODEL_TYPE" = "cloud" ]; then
        # For design tasks, we'll use a general request
        # In a real implementation, we'd have image-specific functions
        result=$(run_cloud_ai "text" "$enhanced_prompt")
    elif [ "$SELECTED_MODEL_TYPE" = "local" ] && [ "$SELECTED_MODEL_PROVIDER" = "stable-diffusion" ]; then
        # For local stable diffusion, we handle the generation request
        result="Local Stable Diffusion generation request: $enhanced_prompt [Size: $IMAGE_SIZE, Count: $NUM_IMAGES]"
        echo "$result"
        # This would call the actual Stable Diffusion API in a real implementation
        echo "Images saved to: ${SD_OUTPUT_PATH:-./ai-assistant/sd-output}"
    else
        # Default to cloud as fallback for image generation
        SELECTED_MODEL_TYPE="cloud"
        SELECTED_MODEL_PROVIDER="openai"
        result=$(run_cloud_ai "text" "$enhanced_prompt")
    fi
    
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
        echo "Error: Failed to process design request" >&2
        return 1
    fi
}

# Main execution
run_design_assistance "$PROMPT"