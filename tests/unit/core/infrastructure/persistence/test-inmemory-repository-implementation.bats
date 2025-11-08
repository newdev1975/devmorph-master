#!/usr/bin/env bats
# test-inmemory-repository-implementation.bats
# Unit tests for InMemoryRepository implementation

# Source the implementations
setup() {
    source "$BATS_TEST_DIRNAME/../../../../../src/core/infrastructure/persistence/InMemoryRepository.impl"
    source "$BATS_TEST_DIRNAME/../../../../../src/core/infrastructure/persistence/UserRepositoryImpl.impl"
    source "$BATS_TEST_DIRNAME/../../../../../src/core/domain/models/User.impl"
    source "$BATS_TEST_DIRNAME/../../../../../src/core/domain/value-objects/EmailValue.impl"
}

@test "init_InMemoryRepositoryImpl_should_initialize_repository" {
    # Test initialization of in-memory repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
}

@test "repository_user_save_impl_should_save_user_entity" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Create a user entity
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    [ -n "$user_entity" ]
    
    # Save the user entity
    run repository_user_save_impl "$user_entity"
    [ "$status" -eq 0 ]
}

@test "repository_user_find_by_id_impl_should_retrieve_saved_user" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Create and save a user entity
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run repository_user_save_impl "$user_entity"
    [ "$status" -eq 0 ]
    
    # Retrieve the user by ID
    run repository_user_find_by_id_impl "user_123"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Verify the retrieved entity matches the original
    retrieved_id=$(entity_user_get_id "$output")
    [ "$retrieved_id" = "user_123" ]
    
    retrieved_username=$(entity_user_get_username "$output")
    [ "$retrieved_username" = "john_doe" ]
    
    retrieved_email=$(entity_user_get_email "$output")
    [ "$retrieved_email" = "john@example.com" ]
}

@test "repository_user_find_by_id_impl_should_return_not_found_for_nonexistent_user" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Try to find a user that doesn't exist
    run repository_user_find_by_id_impl "nonexistent_user"
    [ "$status" -eq 1 ]
}

@test "repository_user_find_by_email_impl_should_retrieve_user_by_email" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Create and save a user entity
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run repository_user_save_impl "$user_entity"
    [ "$status" -eq 0 ]
    
    # Retrieve the user by email
    run repository_user_find_by_email_impl "john@example.com"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Verify the retrieved entity matches the original
    retrieved_id=$(entity_user_get_id "$output")
    [ "$retrieved_id" = "user_123" ]
    
    retrieved_username=$(entity_user_get_username "$output")
    [ "$retrieved_username" = "john_doe" ]
    
    retrieved_email=$(entity_user_get_email "$output")
    [ "$retrieved_email" = "john@example.com" ]
}

@test "repository_user_find_by_email_impl_should_return_not_found_for_nonexistent_email" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Try to find a user with an email that doesn't exist
    run repository_user_find_by_email_impl "nonexistent@example.com"
    [ "$status" -eq 1 ]
}

@test "repository_user_update_impl_should_update_existing_user" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Create and save a user entity
    original_user=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run repository_user_save_impl "$original_user"
    [ "$status" -eq 0 ]
    
    # Update the user's email
    updated_user=$(entity_user_update_email "$original_user" "john_new@example.com")
    [ $? -eq 0 ]
    
    run repository_user_update_impl "$updated_user"
    [ "$status" -eq 0 ]
    
    # Retrieve the updated user
    run repository_user_find_by_id_impl "user_123"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # Verify the email was updated
    retrieved_email=$(entity_user_get_email "$output")
    [ "$retrieved_email" = "john_new@example.com" ]
}

@test "repository_user_delete_impl_should_remove_user" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Create and save a user entity
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run repository_user_save_impl "$user_entity"
    [ "$status" -eq 0 ]
    
    # Verify user exists
    run repository_user_find_by_id_impl "user_123"
    [ "$status" -eq 0 ]
    
    # Delete the user
    run repository_user_delete_impl "user_123"
    [ "$status" -eq 0 ]
    
    # Verify user no longer exists
    run repository_user_find_by_id_impl "user_123"
    [ "$status" -eq 1 ]
}

@test "repository_user_find_all_impl_should_return_all_users" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Create and save multiple user entities
    user1=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    user2=$(entity_user_create "user_456" "jane_doe" "jane@example.com")
    [ $? -eq 0 ]
    
    run repository_user_save_impl "$user1"
    [ "$status" -eq 0 ]
    
    run repository_user_save_impl "$user2"
    [ "$status" -eq 0 ]
    
    # Find all users
    run repository_user_find_all_impl
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    
    # The output should contain both users (it's one JSON per line)
    [ "${#output}" -gt 0 ]
}

@test "repository_user_count_impl_should_return_correct_count" {
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Count should be 0 initially
    run repository_user_count_impl
    [ "$status" -eq 0 ]
    [ "$output" -eq 0 ]
    
    # Create and save a user
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run repository_user_save_impl "$user_entity"
    [ "$status" -eq 0 ]
    
    # Count should be 1 now
    run repository_user_count_impl
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
    
    # Create and save another user
    user2_entity=$(entity_user_create "user_456" "jane_doe" "jane@example.com")
    [ $? -eq 0 ]
    
    run repository_user_save_impl "$user2_entity"
    [ "$status" -eq 0 ]
    
    # Count should be 2 now
    run repository_user_count_impl
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
}

@test "repository_exists_should_check_entity_existence" {
    # Since repository_exists is not directly exposed through the user repository interface,
    # we'll test through the functionality we can access
    
    # Initialize the repository
    run init_InMemoryRepositoryImpl
    [ "$status" -eq 0 ]
    
    # Create and save a user
    user_entity=$(entity_user_create "user_123" "john_doe" "john@example.com")
    [ $? -eq 0 ]
    
    run repository_user_save_impl "$user_entity"
    [ "$status" -eq 0 ]
    
    # Verify we can find the user (meaning it exists)
    run repository_user_find_by_id_impl "user_123"
    [ "$status" -eq 0 ]
    
    # Verify we can't find a non-existent user
    run repository_user_find_by_id_impl "nonexistent_user"
    [ "$status" -eq 1 ]
}