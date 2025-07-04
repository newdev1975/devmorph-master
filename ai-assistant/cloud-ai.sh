#!/bin/sh
# Cloud AI Models Integration Script
# POSIX-compliant script to manage cloud AI model integration

set -e

# Load configuration and libraries
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/lib/model-selector.sh"
. "$SCRIPT_DIR/lib/hardware-detector.sh"

# Function to send a request to Qwen Code API
send_qwen_code_request() {
    prompt="$1"
    max_tokens="${2:-2048}"
    
    # Check if API key is set
    if [ -z "$QWEN_CODE_API_KEY" ]; then
        echo "Error: QWEN_CODE_API_KEY environment variable not set" >&2
        return 1
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl not available for API requests" >&2
        return 1
    fi
    
    # Create JSON payload
    payload=$(printf '{
        "model": "qwen-max",
        "input": {
            "messages": [
                {
                    "role": "system",
                    "content": "You are a helpful AI coding assistant. Provide accurate, efficient, and well-documented code solutions."
                },
                {
                    "role": "user", 
                    "content": "%s"
                }
            ]
        },
        "parameters": {
            "max_tokens": %d,
            "temperature": 0.7
        }
    }' "$(printf '%s' "$prompt" | sed 's/"/\\"/g')" "$max_tokens")
    
    # Send request to Qwen API
    response=$(curl -s -X POST "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation" \
        -H "Authorization: Bearer $QWEN_CODE_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$payload")
    
    # Extract and return the content
    echo "$response" | grep -o '"text":"[^"]*"' | head -n 1 | cut -d'"' -f4 | sed 's/\\n/\n/g'
}

# Function to send a request to OpenAI API
send_openai_request() {
    prompt="$1"
    model="${2:-gpt-3.5-turbo}"
    max_tokens="${3:-2048}"
    
    # Check if API key is set
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY environment variable not set" >&2
        return 1
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl not available for API requests" >&2
        return 1
    fi
    
    # Create JSON payload
    payload=$(printf '{
        "model": "%s",
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful AI assistant. Provide accurate and concise responses."
            },
            {
                "role": "user",
                "content": "%s"
            }
        ],
        "max_tokens": %d,
        "temperature": 0.7
    }' "$model" "$(printf '%s' "$prompt" | sed 's/"/\\"/g')" "$max_tokens")
    
    # Send request to OpenAI API
    response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$payload")
    
    # Extract and return the content (this is a simplified extraction)
    # In a production environment, you'd want a proper JSON parser like jq
    echo "$response" | grep -o '"content":"[^"]*"' | head -n 1 | cut -d'"' -f4 | sed 's/\\n/\n/g'
}

# Function to send a request to Claude API
send_claude_request() {
    prompt="$1"
    model="${2:-claude-3-haiku-20240307}"
    max_tokens="${3:-2048}"
    
    # Check if API key is set
    if [ -z "$CLAUDE_API_KEY" ]; then
        echo "Error: CLAUDE_API_KEY environment variable not set" >&2
        return 1
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl not available for API requests" >&2
        return 1
    fi
    
    # Create JSON payload
    payload=$(printf '{
        "model": "%s",
        "max_tokens": %d,
        "temperature": 0.7,
        "system": "You are a helpful AI assistant. Provide accurate and concise responses.",
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "%s"
                    }
                ]
            }
        ]
    }' "$model" "$max_tokens" "$(printf '%s' "$prompt" | sed 's/"/\\"/g')")
    
    # Send request to Claude API
    response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: $CLAUDE_API_KEY" \
        -H "Content-Type: application/json" \
        -H "anthropic-version: 2023-06-01" \
        -d "$payload")
    
    # Extract and return the content
    echo "$response" | grep -o '"text":"[^"]*"' | head -n 1 | cut -d'"' -f4 | sed 's/\\n/\n/g'
}

# Function to send a generic request based on selected model
send_cloud_request() {
    provider="$1"
    prompt="$2"
    model="${3:-default}"
    max_tokens="${4:-2048}"
    
    case "$provider" in
        "qwen-code")
            send_qwen_code_request "$prompt" "$max_tokens"
            ;;
        "openai")
            send_openai_request "$prompt" "$model" "$max_tokens"
            ;;
        "claude")
            send_claude_request "$prompt" "$model" "$max_tokens"
            ;;
        *)
            echo "Error: Unknown cloud provider: $provider" >&2
            return 1
            ;;
    esac
}

# Function to select the best cloud provider based on availability
select_best_cloud_provider() {
    # Check the availability of each provider based on API keys
    if [ -n "$QWEN_CODE_API_KEY" ]; then
        echo "qwen-code"
        return 0
    elif [ -n "$OPENAI_API_KEY" ]; then
        echo "openai"
        return 0
    elif [ -n "$CLAUDE_API_KEY" ]; then
        echo "claude"
        return 0
    else
        echo ""  # No providers available
        return 1
    fi
}

# Function to run a cloud AI task
run_cloud_ai() {
    task_type="$1"
    input_data="$2"
    model_preference="${3:-default}"
    
    # Select best available cloud provider
    cloud_provider=$(select_best_cloud_provider)
    if [ -z "$cloud_provider" ]; then
        echo "Error: No cloud AI providers configured (no API keys found)" >&2
        return 1
    fi
    
    echo "Running cloud AI task: $task_type with provider: $cloud_provider"
    
    case "$task_type" in
        "code"|"text")
            send_cloud_request "$cloud_provider" "$input_data" "$model_preference"
            ;;
        *)
            # For now, default to text-based requests for all task types
            # In a full implementation, we'd have specialized functions for images, audio, etc.
            send_cloud_request "$cloud_provider" "$input_data" "$model_preference"
            ;;
    esac
}

# Function to check if required API keys are configured
check_cloud_config() {
    has_qwen=$([ -n "$QWEN_CODE_API_KEY" ] && echo 1 || echo 0)
    has_openai=$([ -n "$OPENAI_API_KEY" ] && echo 1 || echo 0)
    has_claude=$([ -n "$CLAUDE_API_KEY" ] && echo 1 || echo 0)
    
    total=$(expr $has_qwen + $has_openai + $has_claude)
    
    echo "Configured cloud providers: $total"
    [ $has_qwen -eq 1 ] && echo "  - Qwen Code: ✓"
    [ $has_openai -eq 1 ] && echo "  - OpenAI: ✓" 
    [ $has_claude -eq 1 ] && echo "  - Claude: ✓"
    
    if [ $total -eq 0 ]; then
        echo "Warning: No cloud providers configured. Set API keys as environment variables:"
        echo "  export QWEN_CODE_API_KEY='your-key-here'"
        echo "  export OPENAI_API_KEY='your-key-here'"
        echo "  export CLAUDE_API_KEY='your-key-here'"
    fi
}

# Function to test cloud API connectivity
test_cloud_connectivity() {
    provider="$1"
    
    case "$provider" in
        "qwen-code")
            if [ -n "$QWEN_CODE_API_KEY" ]; then
                echo "Testing Qwen Code connectivity..."
                # Simple test request
                response=$(send_qwen_code_request "ping" 10 2>&1)
                if [ $? -eq 0 ]; then
                    echo "✓ Qwen Code connection successful"
                else
                    echo "✗ Qwen Code connection failed: $response"
                fi
            else
                echo "✗ Qwen Code: API key not set"
            fi
            ;;
        "openai")
            if [ -n "$OPENAI_API_KEY" ]; then
                echo "Testing OpenAI connectivity..."
                response=$(send_openai_request "ping" "gpt-3.5-turbo" 10 2>&1)
                if [ $? -eq 0 ]; then
                    echo "✓ OpenAI connection successful"
                else
                    echo "✗ OpenAI connection failed: $response" 
                fi
            else
                echo "✗ OpenAI: API key not set"
            fi
            ;;
        "claude")
            if [ -n "$CLAUDE_API_KEY" ]; then
                echo "Testing Claude connectivity..."
                response=$(send_claude_request "ping" "claude-3-haiku-20240307" 10 2>&1)
                if [ $? -eq 0 ]; then
                    echo "✓ Claude connection successful"
                else
                    echo "✗ Claude connection failed: $response"
                fi
            else
                echo "✗ Claude: API key not set"
            fi
            ;;
        *)
            # Test all configured providers
            test_cloud_connectivity "qwen-code"
            test_cloud_connectivity "openai" 
            test_cloud_connectivity "claude"
            ;;
    esac
}

# Main function to run cloud AI operations
run_cloud_operation() {
    operation="$1"
    shift
    args="$*"
    
    case "$operation" in
        "config")
            check_cloud_config
            ;;
        "test")
            test_cloud_connectivity "$args"
            ;;
        "run")
            if [ $# -lt 2 ]; then
                echo "Usage: $0 run <task_type> <input_data> [model_preference]"
                return 1
            fi
            run_cloud_ai "$1" "$2" "$3"
            ;;
        *)
            echo "Usage: $0 {config|test|run} [args...]"
            echo "  config              - Show cloud provider configuration"
            echo "  test [provider]     - Test connectivity to cloud provider(s)"
            echo "  run <task> <input> [model] - Run a cloud AI task"
            echo ""
            echo "Task types: code, text"
            echo "Providers: qwen-code, openai, claude"
            return 1
            ;;
    esac
}

# If script is executed directly, run based on command line arguments
if [ "$0" = "$BASH_SOURCE" ] || [ -z "$BASH_VERSION" ]; then
    run_cloud_operation "$@"
fi