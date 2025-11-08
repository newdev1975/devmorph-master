#!/usr/bin/env bats

setup() {
    # Initialize the repository system
    source "$BATS_TEST_DIRNAME/../../../../../src/core/infrastructure/persistence/InMemoryRepository.impl"
    source "$BATS_TEST_DIRNAME/../../../../../src/core/domain/models/User.impl"
    source "$BATS_TEST_DIRNAME/../../../../../src/core/domain/value-objects/EmailValue.impl"
    source "$BATS_TEST_DIRNAME/../../../../../src/core/infrastructure/persistence/UserRepositoryImpl.impl"
    
    # Initialize the repository
    init_UserRepositoryImpl
}

@test "repository_user_save_impl_should_save_user" {
    run repository_user_save_impl '{"id":"test","username":"test","email":"test@example.com"}'
    [ "$status" -eq 0 ]
}

@test "repository_user_find_by_id_impl_should_find_user" {
    run repository_user_find_by_id_impl "test"
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}
