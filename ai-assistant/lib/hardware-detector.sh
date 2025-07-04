#!/bin/sh
# Hardware Detection Library
# POSIX-compliant script for detecting hardware capabilities

set -e

# Function to detect operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW*) echo "windows";;
        *)          echo "unknown";;
    esac
}

# Function to get CPU information
get_cpu_info() {
    os=$(detect_os)
    
    case "$os" in
        linux)
            if [ -f /proc/cpuinfo ]; then
                cpu_cores=$(grep -c ^processor /proc/cpuinfo)
                cpu_model=$(grep -m 1 'model name' /proc/cpuinfo | cut -d':' -f2 | sed 's/^ *//;s/ *$//')
            fi
            ;;
        macos)
            cpu_cores=$(sysctl -n hw.ncpu)
            cpu_model=$(sysctl -n hw.model)
            ;;
        *)
            cpu_cores="unknown"
            cpu_model="unknown"
            ;;
    esac
    
    echo "CPU Cores: ${cpu_cores:-"unknown"}"
    echo "CPU Model: ${cpu_model:-"unknown"}"
}

# Function to get memory information
get_memory_info() {
    os=$(detect_os)
    
    case "$os" in
        linux)
            if [ -f /proc/meminfo ]; then
                total_mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
                total_mem_mb=$(expr $total_mem_kb / 1024)
                total_mem_gb=$(expr $total_mem_mb / 1024)
            fi
            ;;
        macos)
            total_mem_bytes=$(sysctl -n hw.memsize)
            total_mem_gb=$(expr $total_mem_bytes / 1024 / 1024 / 1024)
            ;;
        *)
            total_mem_gb="unknown"
            ;;
    esac
    
    echo "RAM: ${total_mem_gb:-"unknown"} GB"
}

# Function to detect GPU and VRAM
detect_gpu() {
    gpu_found=0
    gpu_details=""
    
    # Check for NVIDIA GPUs
    if command -v nvidia-smi >/dev/null 2>&1; then
        if nvidia_smi_output=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>/dev/null); then
            if [ -n "$nvidia_smi_output" ]; then
                gpu_found=1
                gpu_type="NVIDIA"
                
                # Extract VRAM information
                vram_list=$(echo "$nvidia_smi_output" | cut -d',' -f2 | tr -d ' ')
                primary_vram=$(echo "$vram_list" | head -n 1)
                
                gpu_details="NVIDIA GPU with ${primary_vram}MB VRAM"
                gpu_name=$(echo "$nvidia_smi_output" | cut -d',' -f1 | head -n 1)
                
                # Check if VRAM is sufficient for AI models (min 4GB = 4096MB)
                if [ "$primary_vram" -ge 4096 ]; then
                    vram_sufficient=1
                    gpu_details="$gpu_details (Suitable for local AI models)"
                else
                    vram_sufficient=0
                    gpu_details="$gpu_details (Insufficient VRAM for large models)"
                fi
            fi
        fi
    fi
    
    # If no NVIDIA GPU, check for other GPUs via lspci
    if [ "$gpu_found" -eq 0 ]; then
        if command -v lspci >/dev/null 2>&1; then
            if gpu_info=$(lspci | grep -E "(VGA|3D)" | grep -i -E "(nvidia|amd|ati|intel)" | head -n 1); then
                gpu_found=1
                gpu_type="Unknown"
                
                gpu_name=$(echo "$gpu_info" | cut -d' ' -f5-)
                gpu_details="GPU: $gpu_name"
            fi
        elif command -v system_profiler >/dev/null 2>&1 && [ "$(detect_os)" = "macos" ]; then
            # macOS specific GPU detection
            if gpu_info=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Chip|Processor" | head -n 1); then
                gpu_found=1
                gpu_type="Apple"
                
                gpu_name=$(echo "$gpu_info" | cut -d':' -f2 | sed 's/^ *//;s/ *$//')
                gpu_details="Apple GPU: $gpu_name"
                
                # For Apple Silicon, assume sufficient performance
                vram_sufficient=1
                gpu_details="$gpu_details (Suitable for local AI models)"
            fi
        fi
    fi
    
    if [ "$gpu_found" -eq 1 ]; then
        echo "GPU detected: $gpu_details"
        return 0
    else
        echo "No compatible GPU detected"
        return 1
    fi
}

# Function to get disk space information
get_disk_info() {
    # Check available space in the home directory
    if command -v df >/dev/null 2>&1; then
        available_space=$(df -h ~ | awk 'NR==2 {print $4}' 2>/dev/null)
        echo "Available disk space: ${available_space:-"unknown"}"
    else
        echo "Available disk space: unknown"
    fi
}

# Function to check if hardware is suitable for running local AI models
is_suitable_for_local_ai() {
    # First check if we have a GPU with sufficient VRAM
    if [ "$vram_sufficient" = "1" ]; then
        echo "1"  # Suitable
        return 0
    fi
    
    # If no GPU with sufficient VRAM, check CPU cores and RAM
    os=$(detect_os)
    case "$os" in
        linux)
            if [ -f /proc/cpuinfo ] && [ -f /proc/meminfo ]; then
                cpu_cores=$(grep -c ^processor /proc/cpuinfo)
                total_mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
                total_mem_gb=$(expr $total_mem_kb / 1024 / 1024)
            fi
            ;;
        macos)
            cpu_cores=$(sysctl -n hw.ncpu)
            total_mem_bytes=$(sysctl -n hw.memsize)
            total_mem_gb=$(expr $total_mem_bytes / 1024 / 1024 / 1024)
            ;;
        *)
            cpu_cores=0
            total_mem_gb=0
            ;;
    esac
    
    # Local AI models generally need at least 4GB RAM and 4+ CPU cores for reasonable performance
    if [ "$total_mem_gb" -ge 4 ] && [ "$cpu_cores" -ge 4 ]; then
        echo "1"  # Suitable
        return 0
    else
        echo "0"  # Not suitable
        return 1
    fi
}

# Main function to run complete hardware detection
run_hardware_detection() {
    echo "=== Hardware Detection Report ==="
    echo "OS: $(detect_os)"
    echo ""
    
    echo "--- CPU Information ---"
    get_cpu_info
    echo ""
    
    echo "--- Memory Information ---"
    get_memory_info
    echo ""
    
    echo "--- GPU Information ---"
    detect_gpu
    echo ""
    
    echo "--- Storage Information ---"
    get_disk_info
    echo ""
    
    echo "--- AI Suitability ---"
    if [ "$(is_suitable_for_local_ai)" = "1" ]; then
        echo "Hardware is suitable for running local AI models"
    else
        echo "Hardware may not be suitable for running local AI models"
        echo "Consider using cloud-based AI services"
    fi
    echo "================================"
}

# If script is run directly, execute the detection
if [ "$0" = "$BASH_SOURCE" ] || [ -z "$BASH_VERSION" ]; then
    run_hardware_detection
fi