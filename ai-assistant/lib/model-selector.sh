#!/bin/sh
# Model Selector Library
# POSIX-compliant script for selecting appropriate AI models based on hardware

set -e

# Source hardware detection library
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/hardware-detector.sh"

# Default model selection strategy
SELECTED_MODEL_TYPE="cloud"  # Default to cloud models
SELECTED_MODEL_PROVIDER="qwen-code"  # Default provider

# Function to select the best model based on hardware capabilities
select_best_model() {
    # Load model configuration
    if [ -f "../config/ai-models.json" ]; then
        CONFIG_FILE="../config/ai-models.json"
    elif [ -f "./config/ai-models.json" ]; then
        CONFIG_FILE="./config/ai-models.json"
    else
        echo "Warning: Configuration file not found, using cloud models as default"
        SELECTED_MODEL_TYPE="cloud"
        SELECTED_MODEL_PROVIDER="qwen-code"
        return
    fi
    
    # Check if hardware is suitable for local models
    if [ "$(is_suitable_for_local_ai)" = "1" ]; then
        # Hardware is suitable for local models, check GPU specifically
        if [ "$vram_sufficient" = "1" ]; then
            # GPU with sufficient VRAM available, prefer GPU-accelerated models
            SELECTED_MODEL_TYPE="local"
            SELECTED_MODEL_PROVIDER="llama-cpp"
            echo "Selected local GPU-accelerated model: llama-cpp"
        else
            # Sufficient CPU/RAM but no GPU, use CPU-based local models or cloud
            # For performance reasons, we'll still consider cloud models
            SELECTED_MODEL_TYPE="cloud"
            SELECTED_MODEL_PROVIDER="qwen-code"
            echo "Selected cloud model: qwen-code (CPU-only local alternative available)"
        fi
    else
        # Hardware not suitable for local models, use cloud
        SELECTED_MODEL_TYPE="cloud"
        SELECTED_MODEL_PROVIDER="qwen-code"
        echo "Selected cloud model: qwen-code (insufficient hardware for local models)"
    fi
}

# Function to prepare model environment based on selection
prepare_model_environment() {
    model_type="$1"
    model_provider="$2"
    
    case "$model_type" in
        "local")
            case "$model_provider" in
                "llama-cpp")
                    # Check if local model service is running
                    if ! docker ps | grep -q llama-cpp-server; then
                        echo "Starting local Llama.cpp server..."
                        # Start the local server (would call the model manager in a real implementation)
                        echo "Llama.cpp server status: Starting - This would connect to Docker container"
                    else
                        echo "Llama.cpp server is already running"
                    fi
                    ;;
                "stable-diffusion")
                    if ! docker ps | grep -q sd-webui; then
                        echo "Starting local Stable Diffusion service..."
                        echo "Stable Diffusion service status: Starting - This would connect to Docker container"
                    else
                        echo "Stable Diffusion service is already running"
                    fi
                    ;;
                "whisper")
                    if ! docker ps | grep -q whisper-server; then
                        echo "Starting local Whisper service..."
                        echo "Whisper service status: Starting - This would connect to Docker container"
                    else
                        echo "Whisper service is already running"
                    fi
                    ;;
            esac
            ;;
        "cloud")
            # Verify API key is available
            api_key_env_var=""
            case "$model_provider" in
                "qwen-code")
                    api_key_env_var="QWEN_CODE_API_KEY"
                    ;;
                "openai")
                    api_key_env_var="OPENAI_API_KEY"
                    ;;
                "claude")
                    api_key_env_var="CLAUDE_API_KEY"
                    ;;
            esac
            
            if [ -n "$api_key_env_var" ] && [ -n "${!api_key_env_var}" ]; then
                echo "Cloud model $model_provider is configured and ready"
            else
                echo "Warning: API key for $model_provider not set in environment variable $api_key_env_var"
                echo "Cloud model $model_provider may not be available"
            fi
            ;;
    esac
}

# Function to get the API endpoint for a cloud model
get_cloud_api_endpoint() {
    provider="$1"
    
    case "$provider" in
        "qwen-code")
            echo "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"
            ;;
        "openai")
            echo "https://api.openai.com/v1/chat/completions"
            ;;
        "claude")
            echo "https://api.anthropic.com/v1/messages"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to get the local API endpoint for a model
get_local_api_endpoint() {
    provider="$1"
    
    case "$provider" in
        "llama-cpp")
            echo "http://localhost:8080"
            ;;
        "stable-diffusion")
            echo "http://localhost:7860"
            ;;
        "whisper")
            echo "http://localhost:9000"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to check model availability
check_model_availability() {
    model_type="$1"
    model_provider="$2"
    
    case "$model_type" in
        "local")
            # Check if the Docker container is running
            container_name=""
            case "$model_provider" in
                "llama-cpp") container_name="llama-cpp-server" ;;
                "stable-diffusion") container_name="sd-webui" ;;
                "whisper") container_name="whisper-server" ;;
            esac
            
            if [ -n "$container_name" ]; then
                if docker ps | grep -q "$container_name"; then
                    echo "1"  # Available
                    return 0
                else
                    echo "0"  # Not available
                    return 1
                fi
            fi
            ;;
        "cloud")
            # Check if API key is set
            api_key_env_var=""
            case "$model_provider" in
                "qwen-code") api_key_env_var="QWEN_CODE_API_KEY" ;;
                "openai") api_key_env_var="OPENAI_API_KEY" ;;
                "claude") api_key_env_var="CLAUDE_API_KEY" ;;
            esac
            
            if [ -n "$api_key_env_var" ] && [ -n "${!api_key_env_var}" ]; then
                echo "1"  # Available
                return 0
            else
                echo "0"  # Not available
                return 1
            fi
            ;;
    esac
    
    echo "0"  # Not available
    return 1
}

# Function to display model selection information
display_model_selection() {
    echo "Model Selection:"
    echo "  Type: $SELECTED_MODEL_TYPE"
    echo "  Provider: $SELECTED_MODEL_PROVIDER"
    
    availability=$(check_model_availability "$SELECTED_MODEL_TYPE" "$SELECTED_MODEL_PROVIDER")
    if [ "$availability" = "1" ]; then
        echo "  Status: Available"
    else
        echo "  Status: Not available"
    fi
    
    if [ "$SELECTED_MODEL_TYPE" = "local" ]; then
        endpoint=$(get_local_api_endpoint "$SELECTED_MODEL_PROVIDER")
        echo "  Endpoint: $endpoint"
    else
        endpoint=$(get_cloud_api_endpoint "$SELECTED_MODEL_PROVIDER")
        echo "  Endpoint: $endpoint"
    fi
}

# Select the best model automatically when the script is sourced
select_best_model