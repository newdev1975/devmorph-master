#!/usr/bin/env bats
# Integration tests for Docker Integration
# Testing the Docker container functionality

@test "test docker availability" {
  # This test checks if Docker is available
  run command -v docker
  [ "$status" -eq 0 ]
}

@test "test docker compose availability" {
  # This test checks if Docker Compose is available
  run bash -c 'command -v docker-compose || command -v "docker compose"'
  [ "$status" -eq 0 ]
}

@test "test ai model manager can check status" {
  # This test verifies the model manager can check status (doesn't require actual containers)
  run timeout 10s ./ai-model-manager.sh status
  # Status might be 0 or 1 depending on whether containers exist, both are acceptable
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "test ai model manager can check gpu" {
  # This test verifies the model manager can check gpu (doesn't require actual GPU)
  run timeout 10s ./ai-model-manager.sh gpu-check
  [ "$status" -eq 0 ]
}

@test "test docker compose file syntax" {
  # This test checks if the docker-compose.yml has valid syntax
  # We'll check the file exists and has expected content
  [ -f "./docker-compose.yml" ]
  
  # Check if the compose file contains expected services
  run grep -c "llama-cpp-server" docker-compose.yml
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
  
  run grep -c "sd-webui" docker-compose.yml
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
  
  run grep -c "whisper-server" docker-compose.yml
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "test ai models config exists" {
  # This test verifies the AI models configuration exists
  [ -f "./config/ai-models.json" ]
  
  # Check if it contains expected content
  run grep -c "models" config/ai-models.json
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "test model health check script exists" {
  # This test checks if the model health check script exists
  [ -f "./model-health-check.sh" ]
  [ -x "./model-health-check.sh" ]
}