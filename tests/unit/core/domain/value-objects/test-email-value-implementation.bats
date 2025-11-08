#!/usr/bin/env bats
# test-email-value-implementation.bats
# Unit tests for EmailValue implementation

# Source the email value implementation
setup() {
    source "$BATS_TEST_DIRNAME/../../../../../src/core/domain/value-objects/EmailValue.impl"
}

@test "entity_email_create_should_create_valid_email_value" {
    # Test creating a valid email value object
    run entity_email_create "test@example.com"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Check that the output contains expected fields
    [[ "$output" =~ "value" ]]
    [[ "$output" =~ "test@example.com" ]]
    [[ "$output" =~ "created_at" ]]
}

@test "entity_email_create_should_fail_with_invalid_email" {
    # Test creating with invalid email
    run entity_email_create "invalid-email"
    [ "$status" -eq 1 ]
    
    run entity_email_create ""
    [ "$status" -eq 1 ]
    
    run entity_email_create "test@"
    [ "$status" -eq 1 ]
    
    run entity_email_create "@example.com"
    [ "$status" -eq 1 ]
}

@test "entity_email_validate_should_accept_valid_emails" {
    # Test validation of valid emails
    run entity_email_validate "test@example.com"
    [ "$status" -eq 0 ]
    
    run entity_email_validate "user.name@example.com"
    [ "$status" -eq 0 ]
    
    run entity_email_validate "user+tag@example.co.uk"
    [ "$status" -eq 0 ]
    
    run entity_email_validate "user_name@example-domain.com"
    [ "$status" -eq 0 ]
    
    run entity_email_validate "123@example.com"
    [ "$status" -eq 0 ]
}

@test "entity_email_validate_should_reject_invalid_emails" {
    # Test validation of invalid emails
    run entity_email_validate "invalid-email"
    [ "$status" -eq 1 ]
    
    run entity_email_validate ""
    [ "$status" -eq 1 ]
    
    run entity_email_validate "@example.com"
    [ "$status" -eq 1 ]
    
    run entity_email_validate "test@"
    [ "$status" -eq 1 ]
    
    run entity_email_validate "test example.com"
    [ "$status" -eq 1 ]
    
    run entity_email_validate "test@@example.com"
    [ "$status" -eq 1 ]
    
    run entity_email_validate "test@.com"
    [ "$status" -eq 1 ]
    
    run entity_email_validate "test@example."
    [ "$status" -eq 1 ]
}

@test "entity_email_validate_should_work_with_email_json_objects" {
    # Test validation of email JSON objects
    email_json='{"value":"test@example.com","created_at":"2023-01-01T00:00:00Z"}'
    run entity_email_validate "$email_json"
    [ "$status" -eq 0 ]
    
    invalid_email_json='{"value":"invalid-email","created_at":"2023-01-01T00:00:00Z"}'
    run entity_email_validate "$invalid_email_json"
    [ "$status" -eq 1 ]
}

@test "entity_email_get_value_should_extract_email_from_json" {
    # Test extracting email from JSON object
    email_json='{"value":"test@example.com","created_at":"2023-01-01T00:00:00Z"}'
    run entity_email_get_value "$email_json"
    [ "$status" -eq 0 ]
    [ "$output" = "test@example.com" ]
}

@test "entity_email_get_value_should_fail_with_invalid_json" {
    # Test that extraction fails with invalid JSON
    run entity_email_get_value ""
    [ "$status" -eq 1 ]
    
    run entity_email_get_value '{"invalid": "json"}'
    [ "$status" -eq 1 ]
    
    run entity_email_get_value "not-json"
    [ "$status" -eq 1 ]
}

@test "email_value_get_domain_should_extract_domain_part" {
    # Test extracting domain part from email
    run email_value_get_domain "test@example.com"
    [ "$status" -eq 0 ]
    [ "$output" = "example.com" ]
    
    run email_value_get_domain "user.name@sub.domain.com"
    [ "$status" -eq 0 ]
    [ "$output" = "sub.domain.com" ]
}

@test "email_value_get_domain_should_fail_with_invalid_email" {
    # Test that domain extraction fails with invalid email
    run email_value_get_domain "invalid-email"
    [ "$status" -eq 1 ]
    
    run email_value_get_domain ""
    [ "$status" -eq 1 ]
}

@test "email_value_get_local_part_should_extract_local_part" {
    # Test extracting local part from email
    run email_value_get_local_part "test@example.com"
    [ "$status" -eq 0 ]
    [ "$output" = "test" ]
    
    run email_value_get_local_part "user.name@sub.domain.com"
    [ "$status" -eq 0 ]
    [ "$output" = "user.name" ]
}

@test "email_value_get_local_part_should_fail_with_invalid_email" {
    # Test that local part extraction fails with invalid email
    run email_value_get_local_part "invalid-email"
    [ "$status" -eq 1 ]
    
    run email_value_get_local_part ""
    [ "$status" -eq 1 ]
}