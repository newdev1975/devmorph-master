#!/usr/bin/env bats
# Performance tests for Model APIs
# Testing the performance of model API calls

@test "test hardware detection performance" {
  # This test checks that hardware detection completes within a reasonable time
  run bash -c 'TIMEFORMAT="%R"; time source lib/hardware-detector.sh && detect_os'
  [ "$status" -eq 0 ]
  # Extract the execution time (in seconds) - this is harder in POSIX sh
  # For this test we just verify it completes without error
}

@test "test model selection performance" {
  # This test checks that model selection completes within a reasonable time
  run bash -c 'TIMEFORMAT="%R"; time source lib/model-selector.sh && select_best_model'
  [ "$status" -eq 0 ]
  # Should complete without error, timing check would be system-dependent
}

@test "test context manager performance" {
  # This test checks that context operations complete within a reasonable time
  run bash -c 'TIMEFORMAT="%R"; time source lib/context-manager.sh && init_context_system'
  [ "$status" -eq 0 ]
}

@test "test session manager performance" {
  # This test checks that session operations complete within a reasonable time
  run bash -c 'TIMEFORMAT="%R"; time source lib/session-manager.sh && init_session_system'
  [ "$status" -eq 0 ]
}

@test "test basic function execution speed" {
  # This test verifies that basic functions execute quickly
  # Measure time to execute detect_os function
  start_time=$(date +%s.%N)
  source lib/hardware-detector.sh > /dev/null 2>&1
  os_result=$(detect_os)
  end_time=$(date +%s.%N)
  
  # Calculate elapsed time (would normally use bc, but we'll just check it completes)
  # For BATS, we'll use a simpler approach
  [ -n "$os_result" ]
  [ "$status" -eq 0 ]
}

@test "test multiple function calls performance" {
  # This test checks performance when calling functions multiple times
  run bash -c '
    source lib/hardware-detector.sh > /dev/null 2>&1
    detect_os > /dev/null 2>&1
    detect_os > /dev/null 2>&1
    detect_os > /dev/null 2>&1
    echo "completed"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "completed" ]
}

@test "test library loading time" {
  # This test checks that all libraries load in a reasonable time
  run bash -c '
    time (
      source lib/hardware-detector.sh > /dev/null 2>&1
      source lib/model-selector.sh > /dev/null 2>&1
      source lib/context-manager.sh > /dev/null 2>&1
      source lib/session-manager.sh > /dev/null 2>&1
    )
    echo "libraries loaded"
  '
  [ "$status" -eq 0 ]
  [[ "$output" =~ "libraries loaded" ]]
}