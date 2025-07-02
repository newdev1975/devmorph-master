#!/bin/sh
# Compatibility Script for DevMorph AI Studio
# Checks system compatibility and dependencies

# Exit on error
set -e

# Source helpers library with error handling
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"

# Check if library files exist before sourcing
if [ ! -f "$LIB_DIR/helpers.sh" ]; then
    echo "ERROR [$(basename "$0")] Helpers library not found: $LIB_DIR/helpers.sh" >&2
    exit 1
fi

if [ ! -f "$LIB_DIR/logger.sh" ]; then
    echo "ERROR [$(basename "$0")] Logger library not found: $LIB_DIR/logger.sh" >&2
    exit 1
fi

# Source all libraries
. "$LIB_DIR/helpers.sh"
. "$LIB_DIR/logger.sh"

# Initialize logging
initialize_logger

# Function to check POSIX compliance
check_posix_compliance() {
    log_info "Checking POSIX compliance..."
    
    # Check if basic POSIX commands are available
    local missing_commands=""
    
    for cmd in sh echo grep sed awk cut tr; do
        if ! command_exists "$cmd"; then
            missing_commands="$missing_commands $cmd"
        fi
    done
    
    if [ -n "$missing_commands" ]; then
        log_error "Missing POSIX commands:$missing_commands"
        return 1
    else
        log_info "All required POSIX commands are available"
        return 0
    fi
}

# Function to check Docker compatibility
check_docker_compatibility() {
    log_info "Checking Docker compatibility..."
    
    if ! command_exists docker; then
        log_error "Docker is not installed"
        return 1
    fi
    
    # Check Docker daemon status with timeout to prevent hanging
    if ! timeout 10 docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running or not responding"
        return 1
    fi
    
    # Get Docker version
    docker_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | sed 's/,//' | head -c -20)
    if [ -n "$docker_version" ]; then
        log_info "Docker version: $docker_version"
    else
        log_warn "Could not determine Docker version"
    fi
    
    # Check if Docker Compose is available
    if command_exists docker-compose; then
        compose_version=$(docker-compose --version 2>/dev/null | head -c -40)
        if [ -n "$compose_version" ]; then
            log_info "Docker Compose version: $compose_version"
        else
            log_warn "Docker Compose version could not be determined"
        fi
    elif command_exists docker && docker compose version >/dev/null 2>&1; then
        compose_version=$(docker compose version 2>/dev/null | head -c -40)
        if [ -n "$compose_version" ]; then
            log_info "Docker Compose V2 available: $compose_version"
        else
            log_warn "Docker Compose V2 version could not be determined"
        fi
    else
        log_warn "Docker Compose is not available (some features may be limited)"
    fi
    
    return 0
}

# Function to check system resources
check_system_resources() {
    log_info "Checking system resources..."
    
    # Check available disk space (min 1GB free)
    if command_exists df; then
        # Use -k for kilobyte units and get available space in current directory
        available_space=$(df -k . 2>/dev/null | tail -n +2 | awk '{print $4}' | head -n 1)
        if [ -n "$available_space" ] && [ "$available_space" != "0" ]; then
            available_gb=$((available_space / 1024 / 1024 2>/dev/null))
            if [ -n "$available_gb" ] && [ "$available_gb" -gt 0 ]; then
                if [ $available_gb -lt 1 ]; then
                    log_warn "Less than 1GB available disk space: ${available_gb}GB"
                else
                    log_info "Available disk space: ${available_gb}GB"
                fi
            else
                log_info "Could not determine available disk space"
            fi
        else
            log_warn "Could not determine available disk space"
        fi
    else
        log_warn "df command not available, cannot check disk space"
    fi
    
    # Check if we have memory information (Linux systems)
    if [ -r "/proc/meminfo" ]; then
        # On Linux systems, we can read memory info
        total_memory=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
        if [ -n "$total_memory" ]; then
            total_gb=$((total_memory / 1024 / 1024 2>/dev/null))
            if [ -n "$total_gb" ] && [ "$total_gb" -gt 0 ]; then
                log_info "Total system memory: ${total_gb}GB"
                # Warn if less than 2GB
                if [ $total_gb -lt 2 ]; then
                    log_warn "System has less than 2GB RAM, performance may be affected"
                fi
            fi
        fi
    fi
    
    return 0
}

# Function to check network connectivity (basic check)
check_network_connectivity() {
    log_info "Checking network connectivity..."
    
    # Try to connect to common DNS servers
    if command_exists ping; then
        # Using ping with just one packet and short timeout
        if ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
            log_info "Network connectivity OK"
            return 0
        elif ping -c 1 -W 5 1.1.1.1 >/dev/null 2>&1; then
            log_info "Network connectivity OK"
            return 0
        else
            log_warn "Could not reach public DNS servers (8.8.8.8 or 1.1.1.1), network connectivity might be limited"
            return 0
        fi
    else
        log_warn "ping command not available, cannot check network connectivity"
        return 0
    fi
}

# Function to check system architecture
check_architecture() {
    log_info "Checking system architecture..."
    
    architecture=$(uname -m)
    case "$architecture" in
        x86_64|aarch64|arm64|amd64)
            log_info "Architecture: $architecture (supported)"
            ;;
        *)
            log_warn "Architecture: $architecture (not officially supported)"
            ;;
    esac
    
    return 0
}

# Function to check user permissions
check_permissions() {
    log_info "Checking user permissions..."
    
    # Check if we can write to current directory
    if ! touch .devmorph_permissions_test 2>/dev/null; then
        log_error "Cannot write to current directory"
        return 1
    else
        rm -f .devmorph_permissions_test
    fi
    
    # Check if we have Docker permissions
    if command_exists docker; then
        if ! docker ps >/dev/null 2>&1; then
            log_warn "Docker command available but no permissions to run containers (need to be in docker group or run as root)"
        fi
    fi
    
    return 0
}

# Main compatibility check function
check_compatibility() {
    log_info "Starting compatibility check for DevMorph AI Studio..."
    
    # Set log level based on environment
    if [ "$DEVMORPH_DEBUG" = "1" ]; then
        set_log_level "debug"
    fi
    
    # Run all checks
    local all_checks_passed=true
    
    if ! check_posix_compliance; then
        all_checks_passed=false
        log_error "POSIX compliance check failed"
    fi
    
    if ! check_docker_compatibility; then
        all_checks_passed=false
        log_error "Docker compatibility check failed"
    fi
    
    if ! check_system_resources; then
        log_warn "System resources check had issues"
    fi
    
    if ! check_network_connectivity; then
        log_warn "Network connectivity check had issues"
    fi
    
    if ! check_architecture; then
        log_warn "Architecture check had issues"
    fi
    
    if ! check_permissions; then
        all_checks_passed=false
        log_error "Permissions check failed"
    fi
    
    if [ "$all_checks_passed" = true ]; then
        log_info "All compatibility checks passed!"
        return 0
    else
        log_error "Some compatibility checks failed, see above for details"
        return 1
    fi
}

# If this script is called directly (not sourced), run the check
if [ "$(basename "$0")" = "compatibility.sh" ]; then
    check_compatibility
fi