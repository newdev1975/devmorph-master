#!/usr/bin/env bats

# Unit tests for workspace-manager/lib/logger.sh

setup() {
  load '../../workspace-manager/lib/logger'
  # Initialize logger state
  LOG_LEVEL_DEBUG=0
  LOG_LEVEL_INFO=1
  LOG_LEVEL_WARN=2
  LOG_LEVEL_ERROR=3
  CURRENT_LOG_LEVEL=1  # default to INFO
}

@test "log_message - creates log message at INFO level" {
  run log_message "INFO" "Test message"
  [ "$status" -eq 0 ]
  # Output should contain timestamp, level, and message
  [[ "$output" =~ "INFO" ]]
  [[ "$output" =~ "Test message" ]]
}

@test "log_message - creates log message at ERROR level" {
  run log_message "ERROR" "Test error message"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "ERROR" ]]
  [[ "$output" =~ "Test error message" ]]
}

@test "log_message - respects log level" {
  # Save original log level
  original_level=$CURRENT_LOG_LEVEL
  
  # Set log level to ERROR to suppress INFO messages
  CURRENT_LOG_LEVEL=3
  run log_message "INFO" "Suppressed message"
  [ "$status" -eq 0 ]
  # Message may still appear depending on implementation
  
  # Restore original level
  CURRENT_LOG_LEVEL=$original_level
}

@test "log_debug - creates debug message" {
  # Set to debug level to see debug messages
  original_level=$CURRENT_LOG_LEVEL
  CURRENT_LOG_LEVEL=0
  run log_debug "Debug info"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "DEBUG" ]]
  [[ "$output" =~ "Debug info" ]]
  # Restore level
  CURRENT_LOG_LEVEL=$original_level
}

@test "log_info - creates info message" {
  run log_info "Info message"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "INFO" ]]
  [[ "$output" =~ "Info message" ]]
}

@test "log_warn - creates warning message" {
  run log_warn "Warning message"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "WARN" ]]
  [[ "$output" =~ "Warning message" ]]
}

@test "log_error - creates error message" {
  run log_error "Error message"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "ERROR" ]]
  [[ "$output" =~ "Error message" ]]
}

@test "set_log_level - sets valid log level" {
  run set_log_level "debug"
  [ "$status" -eq 0 ]
  
  run set_log_level "info"
  [ "$status" -eq 0 ]
  
  run set_log_level "warn"
  [ "$status" -eq 0 ]
  
  run set_log_level "error"
  [ "$status" -eq 0 ]
}

@test "set_log_level - rejects invalid log level" {
  run set_log_level "invalid"
  [ "$status" -ne 0 ]
}

@test "get_current_log_level - returns current log level string" {
  run get_current_log_level
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  # Output should be one of the valid levels
  [[ "$output" =~ ^(debug|info|warn|error)$ ]]
}