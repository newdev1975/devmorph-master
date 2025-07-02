#!/usr/bin/env bats

# Integration tests for workspace creation functionality

setup() {
  load '../workspace-manager/lib/validator'
  load '../workspace-manager/lib/helpers'
  load '../workspace-manager/lib/mode-handler'
  load '../workspace-manager/lib/logger'
  # Initialize logger
  initialize_logger 2>/dev/null || true
}

@test "workspace create - basic functionality" {
  # Skip if Docker is not available
  if ! command -v docker >/dev/null 2>&1; then
    skip "Docker not available"
  fi
  
  # Create a temporary directory for testing
  temp_dir=$(mktemp -d)
  original_dir=$(pwd)
  cd "$temp_dir"
  
  # Create a simple template
  mkdir -p templates/test-template
  cat > templates/test-template/Dockerfile << 'EOF'
FROM alpine:latest
CMD ["echo", "test"]
EOF

  # Test that the basic functions work (these are called by workspace-create.sh)
  run validate_workspace_name "test-workspace"
  [ "$status" -eq 0 ]
  
  run validate_template_name "test-template"
  [ "$status" -eq 0 ]
  
  # Clean up
  cd "$original_dir"
  rm -rf "$temp_dir"
}

@test "workspace create - invalid workspace name" {
  run validate_workspace_name "invalid name with spaces"
  [ "$status" -ne 0 ]
  
  run validate_workspace_name "../../../etc"
  [ "$status" -ne 0 ]
}

@test "workspace create - invalid template name" {
  run validate_template_name "invalid template"
  [ "$status" -ne 0 ]
}

@test "workspace lifecycle - path validation" {
  # Test validate_workspace_path function for path traversal
  run validate_workspace_path "."
  [ "$status" -eq 0 ]
  
  run validate_workspace_path ".."
  [ "$status" -ne 0 ]
  
  run validate_workspace_path "../.."
  [ "$status" -ne 0 ]
}

@test "workspace mode - mode switching functionality" {
  # Test validate_mode function
  run validate_mode "dev"
  [ "$status" -eq 0 ]
  
  run validate_mode "prod"
  [ "$status" -eq 0 ]
  
  run validate_mode "invalid"
  [ "$status" -ne 0 ]
  
  # Test get_available_modes
  run get_available_modes
  [ "$status" -eq 0 ]
  [[ "$output" =~ "dev" ]]
  [[ "$output" =~ "prod" ]]
  [[ "$output" =~ "staging" ]]
  [[ "$output" =~ "test" ]]
  [[ "$output" =~ "design" ]]
  [[ "$output" =~ "mix" ]]
}