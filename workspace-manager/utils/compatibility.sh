#!/bin/sh
# Compatibility Script for DevMorph AI Studio
# Checks system compatibility and dependencies

# Exit on error
set -e

# Source helpers library
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
LIB_DIR="$SCRIPT_DIR/lib"
. "$LIB_DIR/helpers.sh"
. "$LIB_DIR/logger.sh"

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
    
    # Check Docker daemon status
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running"
        return 1
    fi
    
    # Get Docker version
    docker_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | sed 's/,//')
    log_info "Docker version: $docker_version"
    
    # Check if Docker Compose is available
    if command_exists docker-compose; then
        compose_version=$(docker-compose --version 2>/dev/null)
        log_info "Docker Compose version: $compose_version"
    elif docker compose version >/dev/null 2>&1; then
        compose_version=$(docker compose version 2>/dev/null)
        log_info "Docker Compose V2 available: $compose_version"
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
        available_space=$(df -k . | tail -1 | awk '{print $4}')
        available_gb=$((available_space / 1024 / 1024))
        
        if [ $available_gb -lt 1 ]; then
            log_warn "Less than 1GB available disk space: ${available_gb}GB"
        else
            log_info "Available disk space: ${available_gb}GB"
        fi
    fi
    
    # Check if enough memory (not possible in pure POSIX shell, so we skip)
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
        else
            log_warn "Could not reach 8.8.8.8, network connectivity might be limited"
            return 0
        fi
    else
        log_warn "ping command not available, cannot check network connectivity"
        return 0
    fi
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
    fi
    
    if ! check_docker_compatibility; then
        all_checks_passed=false
    fi
    
    if ! check_system_resources; then
        all_checks_passed=false
    fi
    
    if ! check_network_connectivity; then
        # Network is not a hard requirement
        log_info "Network connectivity check completed"
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