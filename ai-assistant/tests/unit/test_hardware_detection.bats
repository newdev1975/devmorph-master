#!/usr/bin/env bats
# Unit tests for Hardware Detection
# Testing the hardware detection functionality

load '../../lib/hardware-detector.sh'

@test "test OS detection" {
  run detect_os
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [[ "$output" =~ ^(linux|macos|windows|unknown)$ ]]
}

@test "test CPU information retrieval" {
  run get_cpu_info
  [ "$status" -eq 0 ]
  # Output should contain CPU information
  [ -n "$output" ]
}

@test "test memory information retrieval" {
  run get_memory_info
  [ "$status" -eq 0 ]
  # Output should contain memory information
  [ -n "$output" ]
}

@test "test disk information retrieval" {
  run get_disk_info
  [ "$status" -eq 0 ]
  # Output should contain disk information
  [ -n "$output" ]
}

@test "test GPU detection (may not find GPU on CI)" {
  # This test checks that the function runs without error
  # It may or may not detect a GPU depending on the environment
  run detect_gpu
  # The function returns 0 if GPU detected, 1 if not
  # We just check it runs without crashing
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "test suitability for local AI" {
  # This test checks that the function runs and returns a valid result
  run is_suitable_for_local_ai
  [ "$status" -eq 0 ]
  # Output should be 0 or 1 (string)
  [[ "$output" =~ ^[01]$ ]]
}

@test "test complete hardware detection" {
  # This should run without errors
  run run_hardware_detection
  [ "$status" -eq 0 ]
}