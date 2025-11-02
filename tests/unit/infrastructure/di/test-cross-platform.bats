#!/usr/bin/env bats
# Test: test-cross-platform.bats
# Description: Unit tests for cross-platform functionality

load '../../src/infrastructure/di/Container.impl'
load '../../src/infrastructure/di/utils/DIUtils.impl'
load '../../src/infrastructure/adapters/shell/shell_utils.sh'

@test "shell utilities work correctly" {
    # Test basic logging
    run log_error "Test error message"
    [ "$status" -eq 0 ]
    
    run log_info "Test info message"
    [ "$status" -eq 0 ]
    
    # Test command existence check
    run command_exists "sh"
    [ "$status" -eq 0 ]
    
    run command_exists "nonexistentcommand12345"
    [ "$status" -ne 0 ]
    
    # Test OS detection
    run get_os_type
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Test shell type detection
    run get_shell_type
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "DI utilities are cross-platform compatible" {
    run di_utils_initialize_container
    [ "$status" -eq 0 ]
    
    run di_utils_is_container_initialized
    [ "$status" -eq 0 ]
    
    run di_utils_get_container_stats
    [ "$status" -eq 0 ]
    
    run container_destroy
    [ "$status" -eq 0 ]
}