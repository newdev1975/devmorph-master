#!/usr/bin/env bats

# Unit tests for workspace-manager/lib/validator.sh

setup() {
  load '../../workspace-manager/lib/validator'
  load '../../workspace-manager/lib/helpers'
  load '../../workspace-manager/lib/logger'
  # Initialize logger since validator functions may call log functions
  initialize_logger 2>/dev/null || true
}

@test "validate_workspace_name - valid name" {
  run validate_workspace_name "test-workspace"
  [ "$status" -eq 0 ]
}

@test "validate_workspace_name - invalid characters" {
  run validate_workspace_name "test workspace"  # space not allowed
  [ "$status" -ne 0 ]
}

@test "validate_workspace_name - empty name" {
  run validate_workspace_name ""
  [ "$status" -ne 0 ]
}

@test "validate_workspace_name - too long" {
  long_name=$(printf "%0.sx" {1..70})  # 70 chars
  run validate_workspace_name "$long_name"
  [ "$status" -ne 0 ]
}

@test "validate_workspace_name - reserved name" {
  run validate_workspace_name "."
  [ "$status" -ne 0 ]
  
  run validate_workspace_name ".."
  [ "$status" -ne 0 ]
  
  run validate_workspace_name "/"
  [ "$status" -ne 0 ]
}

@test "validate_template_name - valid name" {
  run validate_template_name "test-template"
  [ "$status" -eq 0 ]
}

@test "validate_template_name - invalid characters" {
  run validate_template_name "test template"
  [ "$status" -ne 0 ]
}

@test "validate_template_name - empty name" {
  run validate_template_name ""
  [ "$status" -ne 0 ]
}

@test "validate_path - valid path" {
  run validate_path "/tmp/test"
  [ "$status" -eq 0 ]
}

@test "validate_path - path with traversal" {
  run validate_path "/tmp/../etc"
  [ "$status" -ne 0 ]
}

@test "validate_path - dangerous patterns" {
  run validate_path "/tmp/.."
  [ "$status" -ne 0 ]
  
  run validate_path "/tmp/../"
  [ "$status" -ne 0 ]
}