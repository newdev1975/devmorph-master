#!/usr/bin/env bats

# Unit tests for workspace-manager/lib/mode-handler.sh

setup() {
  load '../../workspace-manager/lib/mode-handler'
  load '../../workspace-manager/lib/validator'
  load '../../workspace-manager/lib/helpers'
  load '../../workspace-manager/lib/logger'
  # Initialize logger
  initialize_logger 2>/dev/null || true
}

@test "get_available_modes - returns available modes" {
  run get_available_modes
  [ "$status" -eq 0 ]
  # Should contain all expected modes
  [[ "$output" =~ "dev" ]]
  [[ "$output" =~ "prod" ]]
  [[ "$output" =~ "staging" ]]
  [[ "$output" =~ "test" ]]
  [[ "$output" =~ "design" ]]
  [[ "$output" =~ "mix" ]]
}

@test "validate_mode - valid modes" {
  run validate_mode "dev"
  [ "$status" -eq 0 ]
  
  run validate_mode "prod"
  [ "$status" -eq 0 ]
  
  run validate_mode "staging"
  [ "$status" -eq 0 ]
  
  run validate_mode "test"
  [ "$status" -eq 0 ]
  
  run validate_mode "design"
  [ "$status" -eq 0 ]
  
  run validate_mode "mix"
  [ "$status" -eq 0 ]
}

@test "validate_mode - invalid mode" {
  run validate_mode "invalid_mode"
  [ "$status" -ne 0 ]
}

@test "get_mode_path - returns correct path" {
  run get_mode_path "dev"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "/modes/dev" ]]
}

@test "get_workspace_mode_safe - handles non-existent file" {
  # Create a temporary workspace directory without state file
  temp_workspace=$(mktemp -d)
  state_file="$temp_workspace/.devmorph-state"
  
  # Should return "unknown" for non-existent file
  run get_workspace_mode_safe "$temp_workspace"
  [ "$status" -eq 0 ]
  [ "$output" = "unknown" ]
  
  # Clean up
  rm -rf "$temp_workspace"
}

@test "get_workspace_mode_safe - handles existing file" {
  # Create a temporary workspace with a basic state file
  temp_workspace=$(mktemp -d)
  state_file="$temp_workspace/.devmorph-state"
  
  # Create a state file with a specific mode
  mkdir -p "$temp_workspace/.devmorph"
  cat > "$state_file" << EOF
{
  "name": "test",
  "template": "default",
  "mode": "test",
  "created_at": "2023-01-01T00:00:00Z",
  "status": "created"
}
EOF

  run get_workspace_mode_safe "$temp_workspace"
  [ "$status" -eq 0 ]
  [ "$output" = "test" ]
  
  # Clean up
  rm -rf "$temp_workspace"
}