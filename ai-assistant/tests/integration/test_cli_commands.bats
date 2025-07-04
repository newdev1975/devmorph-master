#!/usr/bin/env bats
# Integration tests for CLI Commands
# Testing the CLI command functionality

load '../lib/model-selector'
load '../lib/hardware-detector'

@test "test ai code command basic functionality" {
  # This test verifies that the ai-code.sh script can be invoked
  run timeout 10s bash -c "echo 'test' | ./ai-code.sh --help" 2>/dev/null || true
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "test ai design command basic functionality" {
  # This test verifies that the ai-design.sh script can be invoked
  run timeout 10s bash -c "echo 'test' | ./ai-design.sh --help" 2>/dev/null || true
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "test ai analyze command basic functionality" {
  # This test verifies that the ai-analyze.sh script can be invoked
  run timeout 10s bash -c "echo 'test' | ./ai-analyze.sh --help" 2>/dev/null || true
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "test ai suggest command basic functionality" {
  # This test verifies that the ai-suggest.sh script can be invoked
  run timeout 10s bash -c "echo 'test' | ./ai-suggest.sh --help" 2>/dev/null || true
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "test ai chat command basic functionality" {
  # This test verifies that the ai-chat.sh script can be invoked
  run timeout 10s bash -c "echo 'test' | ./ai-chat.sh --help" 2>/dev/null || true
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "test ai model manager command basic functionality" {
  # This test verifies that the ai-model-manager.sh script can be invoked
  run timeout 5s ./ai-model-manager.sh status 2>/dev/null || true
  [ "$status" -eq 0 ]
}

@test "test local AI script basic functionality" {
  # This test verifies that the local-ai.sh script can be invoked
  run timeout 5s ./local-ai.sh status 2>/dev/null || true
  [ "$status" -eq 0 ]
}

@test "test cloud AI script basic functionality" {
  # This test verifies that the cloud-ai.sh script can be invoked
  run timeout 5s ./cloud-ai.sh config 2>/dev/null || true
  [ "$status" -eq 0 ]
}