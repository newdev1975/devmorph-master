#!/bin/sh
# Model Management and Health Check Script
# POSIX-compliant script for managing AI models and checking their health

set -e

# Load configuration and libraries
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/lib/model-selector.sh"
. "$SCRIPT_DIR/ai-model-manager.sh"

# Function to check the health of a model service
check_model_health() {
    model_type="$1"
    model_provider="$2"
    
    case "$model_type" in
        "local")
            check_local_model_health "$model_provider"
            ;;
        "cloud")
            check_cloud_model_health "$model_provider"
            ;;
        *)
            echo "Error: Unknown model type: $model_type" >&2
            return 1
            ;;
    esac
}

# Function to check health of local models
check_local_model_health() {
    provider="$1"
    
    # Use Docker to check if the container is running
    container_name=""
    health_endpoint=""
    
    case "$provider" in
        "llama-cpp")
            container_name="llama-cpp-server"
            health_endpoint="http://localhost:8080/health"
            ;;
        "stable-diffusion")
            container_name="sd-webui"
            health_endpoint="http://localhost:7860"
            ;;
        "whisper")
            container_name="whisper-server"
            health_endpoint="http://localhost:9000"
            ;;
        *)
            echo "Error: Unknown local model provider: $provider" >&2
            return 1
            ;;
    esac
    
    # Check if container is running
    if ! docker ps | grep -q "$container_name"; then
        echo "Health check failed: Container $container_name is not running"
        return 1
    fi
    
    # Check service health via HTTP endpoint if available
    if [ -n "$health_endpoint" ] && command -v curl >/dev/null 2>&1; then
        # For llama.cpp, try to make a minimal health check request
        if [ "$provider" = "llama-cpp" ]; then
            # Try to send a minimal completion request
            response=$(curl -s -m 10 -o /dev/null -w "%{http_code}" "$health_endpoint" 2>/dev/null || echo "000")
            if [ "$response" = "200" ] || [ "$response" = "400" ]; then  # 400 indicates server is running but bad request
                echo "Health check passed: $provider service is responding"
                return 0
            else
                echo "Health check failed: $provider service not responding (HTTP $response)"
                return 1
            fi
        else
            # For other services, just check if endpoint responds
            response=$(curl -s -m 10 -o /dev/null -w "%{http_code}" "$health_endpoint" 2>/dev/null || echo "000")
            if [ "$response" != "000" ]; then
                echo "Health check passed: $provider service is responding"
                return 0
            else
                echo "Health check failed: $provider service not responding"
                return 1
            fi
        fi
    else
        # If no HTTP check possible, just verify container is running
        echo "Health check passed: $provider container is running"
        return 0
    fi
}

# Function to check health of cloud models (availability check)
check_cloud_model_health() {
    provider="$1"
    
    # Check if the appropriate API key is set
    case "$provider" in
        "qwen-code")
            if [ -n "$QWEN_CODE_API_KEY" ]; then
                echo "Health check passed: Qwen Code API key is configured"
                return 0
            else
                echo "Health check failed: Qwen Code API key not set"
                return 1
            fi
            ;;
        "openai")
            if [ -n "$OPENAI_API_KEY" ]; then
                echo "Health check passed: OpenAI API key is configured"
                return 0
            else
                echo "Health check failed: OpenAI API key not set"
                return 1
            fi
            ;;
        "claude")
            if [ -n "$CLAUDE_API_KEY" ]; then
                echo "Health check passed: Claude API key is configured"
                return 0
            else
                echo "Health check failed: Claude API key not set"
                return 1
            fi
            ;;
        *)
            echo "Error: Unknown cloud model provider: $provider" >&2
            return 1
            ;;
    esac
}

# Function to run health checks on all configured models
run_health_checks() {
    echo "Running health checks on all configured models..."
    
    # Check local models if Docker is available
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        echo "Checking local model health:"
        for provider in llama-cpp stable-diffusion whisper; do
            echo "  Testing $provider..."
            if check_local_model_health "$provider"; then
                echo "    ✓ $provider is healthy"
            else
                echo "    ✗ $provider has issues"
            fi
        done
    else
        echo "Docker not available, skipping local model health checks"
    fi
    
    # Check cloud models
    echo "Checking cloud model health:"
    for provider in qwen-code openai claude; do
        echo "  Testing $provider..."
        if check_cloud_model_health "$provider"; then
            echo "    ✓ $provider is configured"
        else
            echo "    ✗ $provider has issues"
        fi
    done
}

# Function to restart unhealthy models
restart_unhealthy_models() {
    echo "Checking for unhealthy models and restarting..."
    
    restart_count=0
    
    # Check and restart local models if needed
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        for provider in llama-cpp stable-diffusion whisper; do
            if ! check_local_model_health "$provider" 2>/dev/null; then
                echo "Restarting $provider..."
                # Determine container name
                container_name=""
                case "$provider" in
                    "llama-cpp") container_name="llama-cpp-server" ;;
                    "stable-diffusion") container_name="sd-webui" ;;
                    "whisper") container_name="whisper-server" ;;
                esac
                
                if [ -n "$container_name" ]; then
                    docker restart "$container_name" >/dev/null 2>&1 || {
                        # If restart fails, try to start the complete service
                        echo "Full service restart for $provider..."
                        ./ai-model-manager.sh start >/dev/null 2>&1
                    }
                    restart_count=$(expr $restart_count + 1)
                fi
            fi
        done
    fi
    
    echo "Restarted $restart_count unhealthy local model services"
}

# Function to monitor model resource usage
monitor_model_resources() {
    provider="$1"
    
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker not available, cannot monitor resources"
        return 1
    fi
    
    case "$provider" in
        "llama-cpp")
            container_name="llama-cpp-server"
            ;;
        "stable-diffusion")
            container_name="sd-webui"
            ;;
        "whisper")
            container_name="whisper-server"
            ;;
        *)
            echo "Error: Unknown provider for resource monitoring: $provider" >&2
            return 1
            ;;
    esac
    
    # Check if container is running
    if ! docker ps | grep -q "$container_name"; then
        echo "Container $container_name is not running"
        return 1
    fi
    
    # Get resource usage for the container
    echo "Resource usage for $container_name:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" "$container_name"
}

# Function to get model usage statistics
get_model_usage_stats() {
    # In a real implementation, this would track actual usage
    # For now, we'll just return placeholder information
    echo "Model usage statistics:"
    echo "  (This would show actual usage data in a production implementation)"
    echo "  Local models:"
    echo "    - llama-cpp: X requests, Y tokens processed"
    echo "    - stable-diffusion: X generations completed" 
    echo "    - whisper: X audio files processed"
    echo "  Cloud models:"
    echo "    - qwen-code: X requests made"
    echo "    - openai: X requests made"
    echo "    - claude: X requests made"
}

# Function to perform model maintenance
perform_model_maintenance() {
    echo "Performing model maintenance..."
    
    # Check for Docker resources
    if command -v docker >/dev/null 2>&1; then
        echo "Cleaning up Docker resources..."
        # Remove unused containers, networks, images
        docker system prune -f >/dev/null 2>&1 &
        echo "Docker cleanup started in background"
    fi
    
    # In a full implementation, we would also:
    # - Rotate logs
    # - Check disk space
    # - Update model configurations
    # - Verify data integrity
    
    echo "Maintenance tasks completed"
}

# Main function to manage models
manage_models() {
    operation="$1"
    provider="$2"
    
    case "$operation" in
        "health")
            if [ -n "$provider" ]; then
                check_model_health_for_type "$provider"
            else
                run_health_checks
            fi
            ;;
        "restart-unhealthy")
            restart_unhealthy_models
            ;;
        "monitor")
            if [ -n "$provider" ]; then
                monitor_model_resources "$provider"
            else
                echo "Please specify a provider for monitoring (llama-cpp, stable-diffusion, whisper)"
            fi
            ;;
        "stats")
            get_model_usage_stats
            ;;
        "maintain")
            perform_model_maintenance
            ;;
        *)
            echo "Usage: $0 {health|restart-unhealthy|monitor|stats|maintain} [provider]"
            echo "  health [provider]     - Check health of models (or specific provider)"
            echo "  restart-unhealthy     - Restart any unhealthy model services"
            echo "  monitor <provider>    - Monitor resource usage for a provider"  
            echo "  stats                 - Show model usage statistics"
            echo "  maintain              - Perform model maintenance tasks"
            echo ""
            echo "Providers: llama-cpp, stable-diffusion, whisper, qwen-code, openai, claude"
            return 1
            ;;
    esac
}

# Helper function to check health based on provider type
check_model_health_for_type() {
    provider="$1"
    
    # Determine if it's a local or cloud model
    case "$provider" in
        "llama-cpp"|"stable-diffusion"|"whisper")
            check_model_health "local" "$provider"
            ;;
        "qwen-code"|"openai"|"claude")
            check_model_health "cloud" "$provider"
            ;;
        *)
            echo "Error: Unknown provider: $provider" >&2
            return 1
            ;;
    esac
}

# If script is executed directly, run based on command line arguments
if [ "$0" = "$BASH_SOURCE" ] || [ -z "$BASH_VERSION" ]; then
    manage_models "$@"
fi