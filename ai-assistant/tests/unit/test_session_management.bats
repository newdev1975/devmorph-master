#!/usr/bin/env bats
# Unit tests for Session Management
# Testing the session management functionality

load '../../lib/session-manager.sh'

@test "test session system initialization" {
  # The init_session_system function is called automatically when the library is loaded
  [ -d "$SESSION_DIR" ]
}

@test "test create new session" {
  run create_session "test_session_$$"
  [ "$status" -eq 0 ]
  
  # Check that the session file was created
  session_file="$SESSION_DIR/test_session_$$.json"
  [ -f "$session_file" ]
  
  # Clean up
  rm -f "$session_file" "$SESSION_DIR/test_session_$$.lock"
}

@test "test load existing session" {
  # Create a test session first
  create_session "load_test_session_$$"
  
  run load_session "load_test_session_$$"
  [ "$status" -eq 0 ]
  [ "$CURRENT_SESSION" = "load_test_session_$$" ]
  
  # Clean up
  end_session 2>/dev/null || true  # End session if it's still active
  rm -f "$SESSION_DIR/load_test_session_$$.json" "$SESSION_DIR/load_test_session_$$.lock"
}

@test "test increment interaction count" {
  # Create a test session
  create_session "interaction_test_$$"
  load_session "interaction_test_$$"
  
  # Check initial count
  initial_count=$(grep -o '"interaction_count": [0-9]*' "$SESSION_FILE" | cut -d: -f2 | tr -d ' ,')
  [ "$initial_count" = "0" ]
  
  # Increment count
  run increment_interaction_count
  [ "$status" -eq 0 ]
  
  # Check updated count
  updated_count=$(grep -o '"interaction_count": [0-9]*' "$SESSION_FILE" | cut -d: -f2 | tr -d ' ,')
  [ "$updated_count" = "1" ]
  
  # Clean up
  end_session 2>/dev/null || true  # End session if it's still active
  rm -f "$SESSION_DIR/interaction_test_$$.json" "$SESSION_DIR/interaction_test_$$.lock"
}

@test "test update tokens used" {
  # Create a test session
  create_session "tokens_test_$$"
  load_session "tokens_test_$$"
  
  # Check initial token count
  initial_tokens=$(grep -o '"tokens_used": [0-9]*' "$SESSION_FILE" | cut -d: -f2 | tr -d ' ,')
  [ "$initial_tokens" = "0" ]
  
  # Update tokens
  run update_tokens_used 50
  [ "$status" -eq 0 ]
  
  # Check updated token count
  updated_tokens=$(grep -o '"tokens_used": [0-9]*' "$SESSION_FILE" | cut -d: -f2 | tr -d ' ,')
  [ "$updated_tokens" = "50" ]
  
  # Clean up
  end_session 2>/dev/null || true  # End session if it's still active
  rm -f "$SESSION_DIR/tokens_test_$$.json" "$SESSION_DIR/tokens_test_$$.lock"
}

@test "test end session" {
  # Create and load a test session
  create_session "end_test_$$"
  load_session "end_test_$$"
  
  # Verify it's active
  run has_active_session
  [ "$status" -eq 0 ]
  
  # End the session
  run end_session
  [ "$status" -eq 0 ]
  
  # Verify it's no longer active
  run has_active_session
  [ "$status" -eq 1 ]
  
  # Clean up
  rm -f "$SESSION_DIR/end_test_$$.json"
}

@test "test list sessions" {
  run list_sessions
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "test get session stats" {
  # Create and load a test session
  create_session "stats_test_$$"
  load_session "stats_test_$$"
  
  run get_session_stats
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  
  # Clean up
  end_session 2>/dev/null || true  # End session if it's still active
  rm -f "$SESSION_DIR/stats_test_$$.json" "$SESSION_DIR/stats_test_$$.lock"
}