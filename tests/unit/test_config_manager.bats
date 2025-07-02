#!/usr/bin/env bats

# Unit tests for workspace-manager/lib/config-manager.sh

setup() {
  load '../../workspace-manager/lib/config-manager'
  load '../../workspace-manager/lib/validator'
  load '../../workspace-manager/lib/helpers'
  load '../../workspace-manager/lib/logger'
  # Initialize logger
  initialize_logger 2>/dev/null || true
}

@test "read_config_value - reads existing key" {
  # Create a temporary config file
  temp_file=$(mktemp)
  
  cat > "$temp_file" << EOF
{
  "test_key": "test_value",
  "numeric_value": 123,
  "boolean_value": true
}
EOF

  run read_config_value "$temp_file" "test_key"
  [ "$status" -eq 0 ]
  [ "$output" = "test_value" ]
  
  run read_config_value "$temp_file" "numeric_value"
  [ "$status" -eq 0 ]
  [ "$output" = "123" ]
  
  # Clean up
  rm -f "$temp_file"
}

@test "read_config_value - non-existent key" {
  temp_file=$(mktemp)
  
  cat > "$temp_file" << EOF
{
  "test_key": "test_value"
}
EOF

  run read_config_value "$temp_file" "nonexistent_key"
  [ "$status" -ne 0 ]
  
  # Clean up
  rm -f "$temp_file"
}

@test "read_config_value - non-existent file" {
  run read_config_value "/nonexistent/file" "test_key"
  [ "$status" -ne 0 ]
}

@test "write_config_value - writes new key to existing file" {
  temp_file=$(mktemp)
  
  cat > "$temp_file" << EOF
{
  "existing_key": "existing_value"
}
EOF

  run write_config_value "$temp_file" "new_key" "new_value"
  [ "$status" -eq 0 ]
  
  # Verify the new key was added
  run read_config_value "$temp_file" "new_key"
  [ "$status" -eq 0 ]
  [ "$output" = "new_value" ]
  
  # Clean up
  rm -f "$temp_file"
}

@test "write_config_value - updates existing key" {
  temp_file=$(mktemp)
  
  cat > "$temp_file" << EOF
{
  "existing_key": "old_value"
}
EOF

  run write_config_value "$temp_file" "existing_key" "new_value"
  [ "$status" -eq 0 ]
  
  # Verify the value was updated
  run read_config_value "$temp_file" "existing_key"
  [ "$status" -eq 0 ]
  [ "$output" = "new_value" ]
  
  # Clean up
  rm -f "$temp_file"
}

@test "write_config_value - creates file with new key if file doesn't exist" {
  temp_file=$(mktemp)
  rm -f "$temp_file"  # Ensure it doesn't exist
  
  run write_config_value "$temp_file" "test_key" "test_value"
  [ "$status" -eq 0 ]
  
  # Verify the file was created and key was added
  [ -f "$temp_file" ]
  run read_config_value "$temp_file" "test_key"
  [ "$status" -eq 0 ]
  [ "$output" = "test_value" ]
  
  # Clean up
  rm -f "$temp_file"
}

@test "get_global_config_dir - returns config directory path" {
  run get_global_config_dir
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "validate_config_file - valid file" {
  temp_file=$(mktemp)
  
  cat > "$temp_file" << EOF
{
  "test_key": "test_value"
}
EOF

  run validate_config_file "$temp_file"
  [ "$status" -eq 0 ]
  
  # Clean up
  rm -f "$temp_file"
}

@test "validate_config_file - non-existent file" {
  run validate_config_file "/nonexistent/file"
  [ "$status" -ne 0 ]
}