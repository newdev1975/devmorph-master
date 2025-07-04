#!/usr/bin/env bats
# Unit tests for Context Management
# Testing the context management functionality

load '../../lib/context-manager.sh'

@test "test context system initialization" {
  # The init_context_system function is called automatically when the library is loaded
  [ -d "$CONTEXT_DIR" ]
  [ -f "$CONTEXT_DIR/default.json" ]
}

@test "test create new context" {
  run create_context "test_context"
  [ "$status" -eq 0 ]
  [ -f "$CONTEXT_DIR/test_context.json" ]
  
  # Clean up
  rm -f "$CONTEXT_DIR/test_context.json"
}

@test "test load existing context" {
  # Create a test context first
  create_context "load_test"
  
  run load_context "load_test"
  [ "$status" -eq 0 ]
  [ "$CURRENT_CONTEXT" = "load_test" ]
  
  # Clean up
  rm -f "$CONTEXT_DIR/load_test.json"
}

@test "test default context loading" {
  run load_context
  [ "$status" -eq 0 ]
  [ "$CURRENT_CONTEXT" = "default" ]
}

@test "test add file to context" {
  # Create a temporary file to test with
  temp_file=$(mktemp)
  echo "test content" > "$temp_file"
  
  # Create a test context
  create_context "file_test"
  load_context "file_test"
  
  run add_file_to_context "$temp_file"
  [ "$status" -eq 0 ]
  
  # Clean up
  rm -f "$temp_file" "$CONTEXT_DIR/file_test.json"
}

@test "test set context workspace" {
  # Create a temporary directory to test with
  temp_dir=$(mktemp -d)
  
  # Create a test context
  create_context "workspace_test"
  load_context "workspace_test"
  
  run set_context_workspace "$temp_dir"
  [ "$status" -eq 0 ]
  
  # Clean up
  rm -rf "$temp_dir" "$CONTEXT_DIR/workspace_test.json"
}

@test "test list contexts" {
  run list_contexts
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}