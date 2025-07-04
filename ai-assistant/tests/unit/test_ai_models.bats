#!/usr/bin/env bats
# Unit tests for AI Models
# Testing the core functionality of model management

load '../../lib/model-selector.sh'
load '../../lib/hardware-detector.sh'

@test "test detect_os function" {
  run detect_os
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "test get_cpu_info function" {
  run get_cpu_info
  [ "$status" -eq 0 ]
  # This will output CPU information, just checking it runs without errors
}

@test "test get_memory_info function" {
  run get_memory_info
  [ "$status" -eq 0 ]
  # This will output memory information, just checking it runs without errors
}

@test "test model selection on different hardware scenarios" {
  # This test checks if the model selection logic works correctly
  # The actual selection depends on the runtime environment
  run select_best_model
  [ "$status" -eq 0 ]
  [ -n "$SELECTED_MODEL_TYPE" ]
  [ -n "$SELECTED_MODEL_PROVIDER" ]
}

@test "test cloud API endpoint retrieval" {
  run get_cloud_api_endpoint "qwen-code"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "dashscope.aliyuncs.com" ]]
  
  run get_cloud_api_endpoint "openai"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "api.openai.com" ]]
  
  run get_cloud_api_endpoint "claude"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "anthropic.com" ]]
}

@test "test local API endpoint retrieval" {
  run get_local_api_endpoint "llama-cpp"
  [ "$status" -eq 0 ]
  [ "$output" = "http://localhost:8080" ]
  
  run get_local_api_endpoint "stable-diffusion"
  [ "$status" -eq 0 ]
  [ "$output" = "http://localhost:7860" ]
  
  run get_local_api_endpoint "whisper"
  [ "$status" -eq 0 ]
  [ "$output" = "http://localhost:9000" ]
}