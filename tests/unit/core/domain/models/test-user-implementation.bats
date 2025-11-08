#!/usr/bin/env bats
# test-user-implementation.bats
# Unit tests for User implementation

# Source the user implementation
setup() {
    source "$BATS_TEST_DIRNAME/../../../../../src/core/domain/models/User.impl"
}

@test "entity_user_create_should_create_valid_user_entity" {
    # Test creating a valid user entity
    run entity_user_create "user_123" "john_doe" "john@example.com"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Check that the output contains expected fields
    [[ "$output" =~ "id" ]]
    [[ "$output" =~ "user_123" ]]
    [[ "$output" =~ "username" ]]
    [[ "$output" =~ "john_doe" ]]
    [[ "$output" =~ "email" ]]
    [[ "$output" =~ "john@example.com" ]]
    [[ "$output" =~ "created_at" ]]
    [[ "$output" =~ "updated_at" ]]
}

@test "entity_user_create_should_fail_with_empty_parameters" {
    # Test creating user with empty user ID
    run entity_user_create "" "john_doe" "john@example.com"
    [ "$status" -eq 1 ]
    
    # Test creating user with empty username
    run entity_user_create "user_123" "" "john@example.com"
    [ "$status" -eq 1 ]
    
    # Test creating user with empty email
    run entity_user_create "user_123" "john_doe" ""
    [ "$status" -eq 1 ]
    
    # Test creating user with all empty
    run entity_user_create "" "" ""
    [ "$status" -eq 1 ]
}

@test "entity_user_create_should_fail_with_invalid_email" {
    # Test creating user with invalid email
    run entity_user_create "user_123" "john_doe" "invalid-email"
    [ "$status" -eq 1 ]
}

@test "entity_user_create_should_fail_with_invalid_user_id" {
    # Test creating user with invalid user ID format
    run entity_user_create "user with spaces" "john_doe" "john@example.com"
    [ "$status" -eq 1 ]
    
    run entity_user_create "" "john_doe" "john@example.com"
    [ "$status" -eq 1 ]
}

@test "entity_user_create_should_fail_with_invalid_username" {
    # Test creating user with invalid username
    run entity_user_create "user_123" "user with spaces" "john@example.com"
    [ "$status" -eq 1 ]
    
    run entity_user_create "user_123" "" "john@example.com"
    [ "$status" -eq 1 ]
}

@test "entity_user_get_id_should_extract_user_id_from_entity" {
    # Test extracting user ID from entity
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run entity_user_get_id "$user_entity"
    [ "$status" -eq 0 ]
    [ "$output" = "user_123" ]
}

@test "entity_user_get_id_should_fail_with_invalid_entity" {
    # Test that ID extraction fails with invalid entity
    run entity_user_get_id ""
    [ "$status" -eq 1 ]
    
    run entity_user_get_id '{"invalid": "entity"}'
    [ "$status" -eq 1 ]
    
    run entity_user_get_id "not-json"
    [ "$status" -eq 1 ]
}

@test "entity_user_get_username_should_extract_username_from_entity" {
    # Test extracting username from entity
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run entity_user_get_username "$user_entity"
    [ "$status" -eq 0 ]
    [ "$output" = "john_doe" ]
}

@test "entity_user_get_email_should_extract_email_from_entity" {
    # Test extracting email from entity
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run entity_user_get_email "$user_entity"
    [ "$status" -eq 0 ]
    [ "$output" = "john@example.com" ]
}

@test "entity_user_validate_should_validate_valid_user" {
    # Test validation of valid user entity
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run entity_user_validate "$user_entity"
    [ "$status" -eq 0 ]
}

@test "entity_user_validate_should_fail_with_invalid_user" {
    # Test validation of invalid user entity
    run entity_user_validate ""
    [ "$status" -eq 1 ]
    
    run entity_user_validate '{"id":"", "username":"john_doe", "email":"john@example.com"}'
    [ "$status" -eq 1 ]
    
    run entity_user_validate '{"id":"user_123", "username":"", "email":"john@example.com"}'
    [ "$status" -eq 1 ]
    
    run entity_user_validate '{"id":"user_123", "username":"john_doe", "email":"invalid-email"}'
    [ "$status" -eq 1 ]
}

@test "entity_user_update_email_should_update_user_email" {
    # Test updating user email
    original_user=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run entity_user_update_email "$original_user" "john_new@example.com"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Verify the new email is in the updated entity
    updated_email=$(entity_user_get_email "$output")
    [ "$updated_email" = "john_new@example.com" ]
    
    # Verify the user ID remains the same
    updated_id=$(entity_user_get_id "$output")
    [ "$updated_id" = "user_123" ]
    
    # Verify the username remains the same
    updated_username=$(entity_user_get_username "$output")
    [ "$updated_username" = "john_doe" ]
}

@test "entity_user_update_username_should_update_user_username" {
    # Test updating user username
    original_user=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run entity_user_update_username "$original_user" "john_updated"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Verify the new username is in the updated entity
    updated_username=$(entity_user_get_username "$output")
    [ "$updated_username" = "john_updated" ]
    
    # Verify the user ID remains the same
    updated_id=$(entity_user_get_id "$output")
    [ "$updated_id" = "user_123" ]
    
    # Verify the email remains the same
    updated_email=$(entity_user_get_email "$output")
    [ "$updated_email" = "john@example.com" ]
}

@test "entity_user_validate_id_should_validate_valid_ids" {
    # Test validation of valid user IDs
    run entity_user_validate_id "user_123"
    [ "$status" -eq 0 ]
    
    run entity_user_validate_id "user-123"
    [ "$status" -eq 0 ]
    
    run entity_user_validate_id "user123"
    [ "$status" -eq 0 ]
    
    run entity_user_validate_id "a"
    [ "$status" -eq 0 ]
}

@test "entity_user_validate_id_should_reject_invalid_ids" {
    # Test validation of invalid user IDs
    run entity_user_validate_id ""
    [ "$status" -eq 1 ]
    
    run entity_user_validate_id "user with spaces"
    [ "$status" -eq 1 ]
    
    run entity_user_validate_id "user@domain"
    [ "$status" -eq 1 ]
}

@test "entity_user_validate_username_should_validate_valid_usernames" {
    # Test validation of valid usernames
    run entity_user_validate_username "john_doe"
    [ "$status" -eq 0 ]
    
    run entity_user_validate_username "john-doe"
    [ "$status" -eq 0 ]
    
    run entity_user_validate_username "johndoe"
    [ "$status" -eq 0 ]
    
    run entity_user_validate_username "a"
    [ "$status" -eq 0 ]
}

@test "entity_user_validate_username_should_reject_invalid_usernames" {
    # Test validation of invalid usernames
    run entity_user_validate_username ""
    [ "$status" -eq 1 ]
    
    run entity_user_validate_username "john doe"
    [ "$status" -eq 1 ]
    
    run entity_user_validate_username "john@doe"
    [ "$status" -eq 1 ]
}