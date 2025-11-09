#!/usr/bin/env bats
# Integration tests for complete event sourcing workflow
# Tests end-to-end scenarios: create → save → load → replay

setup() {
    # Setup test environment
    export TEST_DIR="${BATS_TEST_TMPDIR}/event_sourcing_test"
    export EVENT_STORAGE_DIR="$TEST_DIR/events"
    export EVENT_STORE_DIR="$TEST_DIR/event_store"
    export USER_AGGREGATE_STATE_DIR="$TEST_DIR/aggregate_state"
    
    mkdir -p "$TEST_DIR"
    
    # Source event sourcing components
    . "${BATS_TEST_DIRNAME}/../../src/core/infrastructure/persistence/EventSourcedRepository.impl"
}

teardown() {
    # Cleanup
    rm -rf "$TEST_DIR"
}

@test "Event Sourcing: Should create user and generate event" {
    # Create user (generates UserRegistered event)
    user_id=$(user_aggregate_create "user_123" "john_doe" "john@example.com")
    
    # Verify
    [ -n "$user_id" ]
    [ "$user_id" = "user_123" ]
}

@test "Event Sourcing: Should append event to event store" {
    # Create user
    user_id=$(user_aggregate_create "user_456" "jane_doe" "jane@example.com")
    
    # Verify event was appended to store
    event_count=$(event_store_count "$user_id")
    [ "$event_count" = "1" ]
}

@test "Event Sourcing: Should load aggregate from event store" {
    # Create user
    user_id=$(user_aggregate_create "user_789" "bob" "bob@example.com")
    
    # Load from event store (replay events)
    event_sourced_repository_load "$user_id"
    
    # Verify loaded successfully
    [ $? -eq 0 ]
}

@test "Event Sourcing: Should reconstruct state from events" {
    # Create user
    user_id=$(user_aggregate_create "user_abc" "alice" "alice@example.com")
    
    # Load and get state
    state=$(event_sourced_repository_find_by_id "$user_id")
    
    # Verify state
    [ -n "$state" ]
    echo "$state" | grep -q "username=alice"
    echo "$state" | grep -q "email=alice@example.com"
}

@test "Event Sourcing: Should find all users" {
    # Create multiple users
    user_aggregate_create "user_001" "user1" "user1@example.com"
    user_aggregate_create "user_002" "user2" "user2@example.com"
    user_aggregate_create "user_003" "user3" "user3@example.com"
    
    # Find all
    all_users=$(event_sourced_repository_find_all)
    
    # Count
    user_count=$(printf "%s" "$all_users" | grep -c '^user_')
    
    [ "$user_count" = "3" ]
}

@test "Event Sourcing: Should check if aggregate exists" {
    # Create user
    user_id=$(user_aggregate_create "user_xyz" "test" "test@example.com")
    
    # Check existence
    event_sourced_repository_exists "$user_id"
    [ $? -eq 0 ]
    
    # Check non-existent
    if event_sourced_repository_exists "non_existent"; then
        return 1
    fi
}

@test "Event Sourcing: Should count aggregates" {
    # Create users
    user_aggregate_create "user_c1" "count1" "c1@example.com"
    user_aggregate_create "user_c2" "count2" "c2@example.com"
    
    # Count
    count=$(event_sourced_repository_count)
    
    [ "$count" = "2" ]
}

@test "Event Sourcing: Should track aggregate version" {
    # Create user
    user_id=$(user_aggregate_create "user_ver" "version_test" "ver@example.com")
    
    # Get version (should be 1 after creation)
    version=$(event_sourced_repository_get_version "$user_id")
    
    [ "$version" = "1" ]
}

@test "Event Sourcing: Should load event stream chronologically" {
    # Create user
    user_id=$(user_aggregate_create "user_stream" "stream_test" "stream@example.com")
    
    # Load event stream
    events=$(event_store_load_stream "$user_id")
    
    # Verify we have events
    [ -n "$events" ]
    
    # Count events
    event_count=$(printf "%s" "$events" | wc -l | tr -d ' ')
    [ "$event_count" = "1" ]
}

@test "Event Sourcing: Should replay events in order" {
    # Create user
    user_id=$(user_aggregate_create "user_replay" "replay_test" "replay@example.com")
    
    # Clear state
    rm -rf "$USER_AGGREGATE_STATE_DIR/$user_id"
    
    # Replay events
    event_stream_replay "$user_id" "user_aggregate_apply_event"
    
    # Verify state was reconstructed
    state=$(user_aggregate_get_state "$user_id")
    [ -n "$state" ]
    echo "$state" | grep -q "username=replay_test"
}

@test "Event Sourcing: Should handle invalid email gracefully" {
    # Try to create user with invalid email
    run user_aggregate_create "user_invalid" "invalid" "not-an-email"
    
    # Should fail
    [ $status -ne 0 ]
}

@test "Event Sourcing: Events should be immutable" {
    # Create user
    user_id=$(user_aggregate_create "user_immut" "immutable" "immut@example.com")
    
    # Get event ID
    event_id=$(event_store_load_stream "$user_id" | head -n 1)
    
    # Get event data
    event_data_before=$(base_event_get_data "$event_id")
    
    # Try to load again (events should not change)
    event_sourced_repository_load "$user_id"
    
    event_data_after=$(base_event_get_data "$event_id")
    
    # Verify immutability
    [ "$event_data_before" = "$event_data_after" ]
}

@test "Event Sourcing: Should provide complete audit trail" {
    # Create user
    user_id=$(user_aggregate_create "user_audit" "audit" "audit@example.com")
    
    # Get all events for audit
    events=$(event_store_load_stream "$user_id")
    
    # Verify each event has timestamp
    printf "%s\n" "$events" | while IFS= read -r event_id; do
        [ -z "$event_id" ] && continue
        
        timestamp=$(base_event_get_timestamp "$event_id")
        [ -n "$timestamp" ]
        [ "$timestamp" -gt 0 ]
    done
}
