#!/bin/sh
# Local AI Models Integration Script
# POSIX-compliant script to manage local AI model integration

set -e

# Load configuration and libraries
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/lib/model-selector.sh"
. "$SCRIPT_DIR/lib/hardware-detector.sh"
. "$SCRIPT_DIR/ai-model-manager.sh"

# Function to download and prepare local models
prepare_local_models() {
    model_type="$1"
    model_size="${2:-base}"  # Default to base models
    
    case "$model_type" in
        "llama")
            download_llama_model "$model_size"
            ;;
        "stable-diffusion")
            download_stable_diffusion_model "$model_size"
            ;;
        "whisper")
            download_whisper_model "$model_size"
            ;;
        *)
            echo "Unknown model type: $model_type" >&2
            return 1
            ;;
    esac
}

# Function to download Llama model
download_llama_model() {
    size="$1"
    model_dir="${MODEL_PATH:-./models}"
    
    # Create models directory if it doesn't exist
    mkdir -p "$model_dir"
    
    case "$size" in
        "tiny")
            model_url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v0.3-GGUF/resolve/main/tinyllama-1.1b-chat-v0.3.Q4_K_M.gguf"
            model_file="$model_dir/tinyllama-1.1b-chat-v0.3.Q4_K_M.gguf"
            ;;
        "base"|"small")
            model_url="https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf" 
            model_file="$model_dir/llama-2-7b-chat.Q4_K_M.gguf"
            ;;
        "large")
            model_url="https://huggingface.co/TheBloke/Llama-2-13B-Chat-GGUF/resolve/main/llama-2-13b-chat.Q4_K_M.gguf"
            model_file="$model_dir/llama-2-13b-chat.Q4_K_M.gguf"
            ;;
        *)
            echo "Unknown model size: $size" >&2
            return 1
            ;;
    esac
    
    if [ -f "$model_file" ]; then
        echo "Model already exists: $model_file"
        return 0
    fi
    
    echo "Downloading Llama model ($size)..."
    if command -v wget >/dev/null 2>&1; then
        wget -O "$model_file" "$model_url" || {
            echo "Failed to download model with wget" >&2
            rm -f "$model_file"  # Clean up partial download
            return 1
        }
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$model_file" "$model_url" || {
            echo "Failed to download model with curl" >&2
            rm -f "$model_file"  # Clean up partial download
            return 1
        }
    else
        echo "Error: Neither wget nor curl available for downloading models" >&2
        return 1
    fi
    
    echo "Llama model downloaded to: $model_file"
}

# Function to download Stable Diffusion model
download_stable_diffusion_model() {
    size="$1"
    model_dir="${SD_MODELS_PATH:-./sd-models}"
    
    # Create models directory if it doesn't exist
    mkdir -p "$model_dir"
    
    # For stable diffusion, we'll use a standard checkpoint model
    case "$size" in
        "base"|"small"|"large")
            model_url="https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt"
            model_file="$model_dir/v1-5-pruned-emaonly.ckpt"
            ;;
        *)
            # Default to the base model
            model_url="https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt"
            model_file="$model_dir/v1-5-pruned-emaonly.ckpt"
            ;;
    esac
    
    if [ -f "$model_file" ]; then
        echo "Model already exists: $model_file"
        return 0
    fi
    
    echo "Downloading Stable Diffusion model..."
    if command -v wget >/dev/null 2>&1; then
        wget -O "$model_file" "$model_url" || {
            echo "Failed to download model with wget" >&2
            rm -f "$model_file"  # Clean up partial download
            return 1
        }
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$model_file" "$model_url" || {
            echo "Failed to download model with curl" >&2
            rm -f "$model_file"  # Clean up partial download
            return 1
        }
    else
        echo "Error: Neither wget nor curl available for downloading models" >&2
        return 1
    fi
    
    echo "Stable Diffusion model downloaded to: $model_file"
}

# Function to download Whisper model
download_whisper_model() {
    size="$1"
    model_dir="${WHISPER_MODELS_PATH:-./whisper-models}"
    
    # Create models directory if it doesn't exist
    mkdir -p "$model_dir"
    
    # Map Whisper sizes to GGML models
    case "$size" in
        "tiny")
            model_file="$model_dir/ggml-tiny.bin"
            model_url="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin"
            ;;
        "base")
            model_file="$model_dir/ggml-base.en.bin"
            model_url="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
            ;;
        "small")
            model_file="$model_dir/ggml-small.en.bin"
            model_url="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin"
            ;;
        "large")
            model_file="$model_dir/ggml-large-v3.bin"
            model_url="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin"
            ;;
        *)
            # Default to base model
            model_file="$model_dir/ggml-base.en.bin"
            model_url="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
            ;;
    esac
    
    if [ -f "$model_file" ]; then
        echo "Model already exists: $model_file"
        return 0
    fi
    
    echo "Downloading Whisper model ($size)..."
    if command -v wget >/dev/null 2>&1; then
        wget -O "$model_file" "$model_url" || {
            echo "Failed to download model with wget" >&2
            rm -f "$model_file"  # Clean up partial download
            return 1
        }
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$model_file" "$model_url" || {
            echo "Failed to download model with curl" >&2
            rm -f "$model_file"  # Clean up partial download
            return 1
        }
    else
        echo "Error: Neither wget nor curl available for downloading models" >&2
        return 1
    fi
    
    echo "Whisper model downloaded to: $model_file"
}

# Function to start local model services based on hardware
start_local_models() {
    # Detect hardware and choose appropriate models
    select_best_model
    
    case "$SELECTED_MODEL_TYPE" in
        "local")
            case "$SELECTED_MODEL_PROVIDER" in
                "llama-cpp")
                    echo "Starting local Llama.cpp service..."
                    start_model_service llama-cpp
                    ;;
                "stable-diffusion")
                    echo "Starting local Stable Diffusion service..."
                    start_model_service stable-diffusion
                    ;;
                "whisper")
                    echo "Starting local Whisper service..."
                    start_model_service whisper
                    ;;
            esac
            ;;
        *)
            echo "Local models not selected, use cloud services instead"
            return 1
            ;;
    esac
}

# Function to start a specific model service
start_model_service() {
    service_name="$1"
    
    # Use the ai-model-manager to start the service
    ./ai-model-manager.sh start
}

# Function to stop local model services
stop_local_models() {
    echo "Stopping local AI model services..."
    ./ai-model-manager.sh stop
}

# Function to check if model services are running
check_model_status() {
    ./ai-model-manager.sh status
}

# Function to send a request to a local model (using curl)
send_local_request() {
    model_type="$1"
    prompt="$2"
    endpoint="$3"
    
    if [ -z "$endpoint" ]; then
        # Use the default endpoint for the model
        case "$model_type" in
            "llama-cpp")
                endpoint="http://localhost:8080"
                ;;
            "stable-diffusion")
                endpoint="http://localhost:7860"
                ;;
            "whisper")
                endpoint="http://localhost:9000"
                ;;
        esac
    fi
    
    case "$model_type" in
        "llama-cpp")
            # Send a completion request to llama.cpp server
            if command -v curl >/dev/null 2>&1; then
                curl -s -X POST "$endpoint/completion" \
                    -H "Content-Type: application/json" \
                    -d "{
                        \"prompt\": \"$prompt\",
                        \"n_predict\": 256,
                        \"temperature\": 0.7,
                        \"top_k\": 40,
                        \"top_p\": 0.9,
                        \"repeat_last_n\": 64,
                        \"repeat_penalty\": 1.1,
                        \"stop\": [\"User:\", \"###\", \"\\n\\n\"]
                    }"
            else
                echo "Error: curl not available for API requests" >&2
                return 1
            fi
            ;;
        "stable-diffusion")
            # This is a simplified request - in practice, Stable Diffusion APIs vary
            echo "Local Stable Diffusion request would go to endpoint: $endpoint"
            ;;
        "whisper")
            # Whisper API is typically for audio transcription
            echo "Local Whisper request would go to endpoint: $endpoint"
            ;;
        *)
            echo "Unknown model type: $model_type" >&2
            return 1
            ;;
    esac
}

# Main function to run local AI models
run_local_ai() {
    task_type="$1"
    input_data="$2"
    
    # Select best local model based on hardware
    select_best_model
    
    if [ "$SELECTED_MODEL_TYPE" != "local" ]; then
        echo "Local models not suitable for this hardware, consider using cloud models"
        return 1
    fi
    
    echo "Running local AI task: $task_type with model: $SELECTED_MODEL_PROVIDER"
    
    case "$task_type" in
        "code"|"text")
            send_local_request "$SELECTED_MODEL_PROVIDER" "$input_data"
            ;;
        "image")
            # For image generation, use stable diffusion if available
            if [ "$SELECTED_MODEL_PROVIDER" = "stable-diffusion" ]; then
                send_local_request "stable-diffusion" "$input_data"
            else
                echo "Stable Diffusion not selected for image generation, using text model instead"
                # Could potentially call image generation models hosted elsewhere
                return 1
            fi
            ;;
        "audio"|"transcribe")
            # For audio transcription, use whisper if available
            if [ "$SELECTED_MODEL_PROVIDER" = "whisper" ]; then
                send_local_request "whisper" "$input_data"
            else
                echo "Whisper not selected for audio processing, using text model instead"
                return 1
            fi
            ;;
        *)
            echo "Unknown task type: $task_type" >&2
            return 1
            ;;
    esac
}

# If script is executed directly, run based on command line arguments
case "${1:-status}" in
    "prepare")
        prepare_local_models "${2:-llama}" "${3:-base}"
        ;;
    "start")
        start_local_models
        ;;
    "stop")
        stop_local_models
        ;;
    "status")
        check_model_status
        ;;
    "run")
        run_local_ai "${2:-text}" "${3:-Hello, world!}"
        ;;
    "download")
        prepare_local_models "${2}" "${3:-base}"
        ;;
    *)
        echo "Usage: $0 {prepare|start|stop|status|run|download} [model_type] [size/prompt]"
        echo "  prepare <model> <size> - Download and prepare local models"
        echo "  start                 - Start local model services"  
        echo "  stop                  - Stop local model services"
        echo "  status                - Check status of model services"
        echo "  run <task> <input>    - Run a local AI task"
        echo "  download <model> <size> - Just download models"
        echo ""
        echo "Model types: llama, stable-diffusion, whisper"
        echo "Sizes: tiny, base, small, large"
        echo "Tasks: code, text, image, audio, transcribe"
        exit 1
        ;;
esac