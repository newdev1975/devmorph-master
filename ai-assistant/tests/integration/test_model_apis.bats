#!/usr/bin/env bats
# Integration tests for Model APIs
# Testing the model API interface functionality

@test "test model selector library loads properly" {
  # This test verifies that the model selector library can be sourced without errors
  run bash -c 'source lib/model-selector.sh'
  [ "$status" -eq 0 ]
}

@test "test hardware detector library loads properly" {
  # This test verifies that the hardware detector library can be sourced without errors
  run bash -c 'source lib/hardware-detector.sh'
  [ "$status" -eq 0 ]
}

@test "test context manager library loads properly" {
  # This test verifies that the context manager library can be sourced without errors
  run bash -c 'source lib/context-manager.sh'
  [ "$status" -eq 0 ]
}

@test "test session manager library loads properly" {
  # This test verifies that the session manager library can be sourced without errors
  run bash -c 'source lib/session-manager.sh'
  [ "$status" -eq 0 ]
}

@test "test local ai script loads dependencies properly" {
  # This test verifies that the local AI script can source its dependencies
  run bash -c 'source local-ai.sh' 2>&1 || true
  # Should complete without syntax errors (may fail for other reasons like missing tools)
  [ "$status" -eq 0 ] || [[ "$output" =~ "command not found" ]] || [[ "$output" =~ "not available" ]]
}

@test "test cloud ai script loads dependencies properly" {
  # This test verifies that the cloud AI script can source its dependencies  
  run bash -c 'source cloud-ai.sh' 2>&1 || true
  # Should complete without syntax errors (may fail for other reasons like missing tools)
  [ "$status" -eq 0 ] || [[ "$output" =~ "command not found" ]] || [[ "$output" =~ "not available" ]]
}

@test "test model selection function exists" {
  # This test verifies the select_best_model function is available
  run bash -c 'source lib/model-selector.sh && type -t select_best_model'
  [ "$status" -eq 0 ]
  [ "$output" = "function" ]
}

@test "test hardware detection functions exist" {
  # This test verifies key hardware detection functions are available
  run bash -c 'source lib/hardware-detector.sh && type -t detect_os'
  [ "$status" -eq 0 ]
  [ "$output" = "function" ]
  
  run bash -c 'source lib/hardware-detector.sh && type -t get_cpu_info'  
  [ "$status" -eq 0 ]
  [ "$output" = "function" ]
  
  run bash -c 'source lib/hardware-detector.sh && type -t get_memory_info'
  [ "$status" -eq 0 ]
  [ "$output" = "function" ]
}