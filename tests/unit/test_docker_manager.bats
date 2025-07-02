#!/usr/bin/env bats

# Unit tests for workspace-manager/lib/docker-manager.sh

setup() {
  load '../../workspace-manager/lib/docker-manager'
  load '../../workspace-manager/lib/helpers'
  load '../../workspace-manager/lib/logger'
  # Initialize logger
  initialize_logger 2>/dev/null || true
}

@test "check_docker - Docker availability" {
  # This test will pass if Docker is available, otherwise it will skip
  if command -v docker >/dev/null 2>&1; then
    run check_docker
    [ "$status" -eq 0 ]
  else
    skip "Docker not available"
  fi
}

@test "check_docker_compose - Docker Compose availability" {
  # This test will pass if Docker Compose is available, otherwise it will skip
  if command -v docker-compose >/dev/null 2>&1 || (command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1); then
    run check_docker_compose
    [ "$status" -eq 0 ]
  else
    skip "Docker Compose not available"
  fi
}

@test "is_workspace_running - handles non-existent workspace" {
  run is_workspace_running "/nonexistent/workspace"
  # Function should return 1 (not running) for non-existent workspace
  [ "$status" -ne 0 ]
}

@test "update_workspace_state - updates state file" {
  # Create a temporary state file
  temp_workspace=$(mktemp -d)
  state_file="$temp_workspace/.devmorph-state"
  
  # Create a basic state file
  cat > "$state_file" << EOF
{
  "name": "test-workspace",
  "template": "default",
  "mode": "dev",
  "created_at": "2023-01-01T00:00:00Z",
  "status": "created"
}
EOF

  # Update the state to "running"
  run update_workspace_state "$temp_workspace" "running"
  [ "$status" -eq 0 ]
  
  # Check that the state was updated
  updated_status=$(grep '"status"' "$state_file" 2>/dev/null | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
  [ "$updated_status" = "running" ]
  
  # Clean up
  rm -rf "$temp_workspace"
}

@test "update_workspace_state - handles non-existent file gracefully" {
  temp_workspace=$(mktemp -d)
  # Don't create the state file initially
  
  # Run update on non-existent file - should not error but may not update anything
  run update_workspace_state "$temp_workspace" "running"
  # Function should handle gracefully without crashing
  
  # Clean up
  rm -rf "$temp_workspace"
}