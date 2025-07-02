#!/bin/sh
# Logger Library for DevMorph AI Studio
# Provides logging functionality with different log levels

# Exit on error
set -e

# Define log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# Set default log level (INFO)
CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO

# Function to set log level
# Arguments:
# $1 - Log level (debug, info, warn, error)
set_log_level() {
    level="$1"
    
    case "$level" in
        "debug")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG
            ;;
        "info")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO
            ;;
        "warn")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_WARN
            ;;
        "error")
            CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR
            ;;
        *)
            echo "Error: Invalid log level. Use debug, info, warn, or error" >&2
            return 1
            ;;
    esac
}

# Function to log a message
# Arguments:
# $1 - Log level
# $2 - Message
log_message() {
    level="$1"
    message="$2"
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    script_name=$(basename "$0")
    
    # Determine numeric level
    case "$level" in
        "DEBUG")
            numeric_level=$LOG_LEVEL_DEBUG
            ;;
        "INFO")
            numeric_level=$LOG_LEVEL_INFO
            ;;
        "WARN")
            numeric_level=$LOG_LEVEL_WARN
            ;;
        "ERROR")
            numeric_level=$LOG_LEVEL_ERROR
            ;;
        *)
            numeric_level=$LOG_LEVEL_INFO  # Default
            level="INFO"
            ;;
    esac
    
    # Only log if current level is less than or equal to message level
    if [ $CURRENT_LOG_LEVEL -le $numeric_level ]; then
        # Use printf with error handling to prevent logging from failing
        if ! printf "%s [%s] [%s] %s\n" "$timestamp" "$level" "$script_name" "$message" 2>/dev/null; then
            # If printf fails, use echo as fallback
            echo "$timestamp [$level] [$script_name] $message" >&2
        fi
    fi
}

# Function to log debug message
log_debug() {
    message="$1"
    log_message "DEBUG" "$message"
}

# Function to log info message
log_info() {
    message="$1"
    log_message "INFO" "$message"
}

# Function to log warning message
log_warn() {
    message="$1"
    log_message "WARN" "$message" >&2
}

# Function to log error message
log_error() {
    message="$1"
    log_message "ERROR" "$message" >&2
}

# Function to log to file
# Arguments:
# $1 - Log file path
# $2 - Message
log_to_file() {
    log_file="$1"
    message="$2"
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    script_name=$(basename "$0")
    
    # Validate log file path to prevent directory traversal
    case "$log_file" in
        */..|*../|*../*|/*|../*)
            echo "Error: Log file path contains dangerous traversal patterns" >&2
            return 1
            ;;
    esac
    
    # Ensure log directory exists with error handling
    log_dir=$(dirname "$log_file")
    if ! mkdir -p "$log_dir" 2>/dev/null; then
        echo "Error: Failed to create log directory: $log_dir" >&2
        return 1
    fi
    
    # Append message to log file with error handling
    if ! printf "%s [INFO] [%s] %s\n" "$timestamp" "$script_name" "$message" >> "$log_file" 2>/dev/null; then
        echo "Error: Failed to write to log file: $log_file" >&2
        return 1
    fi
}

# Initialize logging system
initialize_logger() {
    # Set log level from environment variable if available
    if [ -n "$DEVMORPH_LOG_LEVEL" ]; then
        if ! set_log_level "$DEVMORPH_LOG_LEVEL"; then
            # If invalid log level provided, keep default
            echo "Warning: Invalid DEVMORPH_LOG_LEVEL value: $DEVMORPH_LOG_LEVEL, using default (INFO)" >&2
        fi
    fi
    
    # Create logs directory with error handling
    if ! mkdir -p ".devmorph/logs" 2>/dev/null; then
        echo "Warning: Failed to create logs directory" >&2
    fi
}

# Function to get current log level as string
get_current_log_level() {
    case $CURRENT_LOG_LEVEL in
        $LOG_LEVEL_DEBUG) echo "debug" ;;
        $LOG_LEVEL_INFO) echo "info" ;;
        $LOG_LEVEL_WARN) echo "warn" ;;
        $LOG_LEVEL_ERROR) echo "error" ;;
        *) echo "info" ;;  # Default
    esac
}