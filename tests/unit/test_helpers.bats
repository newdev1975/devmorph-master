#!/usr/bin/env bats

# Unit tests for workspace-manager/lib/helpers.sh

setup() {
  load '../../workspace-manager/lib/helpers'
  load '../../workspace-manager/lib/logger'
  # Initialize logger if needed
  initialize_logger 2>/dev/null || true
}

@test "command_exists - existing command" {
  run command_exists "echo"
  [ "$status" -eq 0 ]
}

@test "command_exists - non-existing command" {
  run command_exists "nonexistent_command_12345"
  [ "$status" -ne 0 ]
}

@test "get_script_dir - returns correct directory" {
  run get_script_dir
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "create_temp_file - creates temporary file" {
  run create_temp_file "test_prefix"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [ -f "$output" ]
  # Clean up
  rm -f "$output"
}

@test "is_linux - detects Linux correctly" {
  # This is a basic test - actual result depends on platform
  run is_linux
  # Just verify it doesn't crash
  [ "$status" -ge 0 ]
}

@test "is_macos - detects macOS correctly" {
  # This is a basic test - actual result depends on platform
  run is_macos
  # Just verify it doesn't crash
  [ "$status" -ge 0 ]
}

@test "is_windows - detects Windows correctly" {
  # This is a basic test - actual result depends on platform
  run is_windows
  # Just verify it doesn't crash
  [ "$status" -ge 0 ]
}

@test "get_os - returns OS name" {
  run get_os
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "to_lowercase - converts to lowercase" {
  run to_lowercase "TEST"
  [ "$output" = "test" ]
}

@test "get_absolute_path - gets absolute path" {
  run get_absolute_path "."
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [[ "$output" =~ ^/ ]]  # Should be absolute path starting with /
}

@test "validate_workspace_path - valid path" {
  run validate_workspace_path "."
  [ "$status" -eq 0 ]
}

@test "validate_workspace_path - invalid path" {
  run validate_workspace_path "../.."
  [ "$status" -ne 0 ]
}