#!/bin/sh
# AI Model Management Script
# POSIX-compliant script for managing AI model containers

set -e

# Load configuration
CONFIG_FILE="${CONFIG_FILE:-./config/ai-models.json}"

# Function to check if Docker is available
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: Docker is not installed or not in PATH" >&2
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker daemon is not running" >&2
        exit 1
    fi
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker compose >/dev/null 2>&1 && ! command -v docker-compose >/dev/null 2>&1; then
        echo "Error: Docker Compose is not installed" >&2
        exit 1
    fi
}

# Function to check GPU availability
check_gpu() {
    gpu_available=0
    
    # Check for NVIDIA GPU
    if command -v nvidia-smi >/dev/null 2>&1; then
        if nvidia-smi >/dev/null 2>&1; then
            gpu_info=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -n 1)
            if [ -n "$gpu_info" ] && [ "$gpu_info" -gt 0 ]; then
                gpu_available=1
                echo "NVIDIA GPU detected with $(echo $gpu_info | cut -d' ' -f1)MB VRAM"
                return
            fi
        fi
    fi
    
    # Check for other GPUs via lspci
    if command -v lspci >/dev/null 2>&1; then
        if lspci | grep -E "(VGA|3D)" | grep -i -E "(nvidia|amd|ati|intel)" >/dev/null; then
            gpu_available=1
            echo "GPU detected via lspci"
            return
        fi
    fi
    
    echo "No GPU detected"
}

# Function to start AI model containers
start_models() {
    echo "Starting AI model containers..."
    check_docker
    check_docker_compose
    
    # Set GPU availability flag for Docker Compose
    export N_GPU=0
    check_gpu
    
    # Start all services in the background
    docker compose -f docker-compose.yml up -d
    
    echo "AI model containers started successfully"
    
    # Wait a bit and show container status
    sleep 3
    docker compose -f docker-compose.yml ps
}

# Function to stop AI model containers
stop_models() {
    echo "Stopping AI model containers..."
    check_docker
    check_docker_compose
    
    docker compose -f docker-compose.yml down
    
    echo "AI model containers stopped successfully"
}

# Function to restart AI model containers
restart_models() {
    echo "Restarting AI model containers..."
    stop_models
    sleep 2
    start_models
}

# Function to check the status of AI model containers
status_models() {
    echo "Checking status of AI model containers..."
    check_docker
    check_docker_compose
    
    docker compose -f docker-compose.yml ps
}

# Function to pull the latest images
pull_images() {
    echo "Pulling latest AI model images..."
    check_docker
    check_docker_compose
    
    docker compose -f docker-compose.yml pull
    
    echo "Images pulled successfully"
}

# Function to show logs for containers
show_logs() {
    service_name=${1:-""}
    if [ -z "$service_name" ]; then
        docker compose -f docker-compose.yml logs
    else
        docker compose -f docker-compose.yml logs "$service_name"
    fi
}

# Main script logic
case "${1:-status}" in
    start)
        start_models
        ;;
    stop)
        stop_models
        ;;
    restart)
        restart_models
        ;;
    status)
        status_models
        ;;
    pull)
        pull_images
        ;;
    logs)
        show_logs "$2"
        ;;
    gpu-check)
        check_gpu
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|pull|logs [service]|gpu-check}"
        echo "  start       - Start AI model containers"
        echo "  stop        - Stop AI model containers" 
        echo "  restart     - Restart AI model containers"
        echo "  status      - Show status of AI model containers"
        echo "  pull        - Pull latest AI model images"
        echo "  logs [svc]  - Show logs (for specific service or all)"
        echo "  gpu-check   - Check GPU availability"
        exit 1
        ;;
esac