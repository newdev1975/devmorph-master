#!/usr/bin/env bats

setup() {
    source src/core/application/commands/UserCreateCommand.interface
}

@test "command_user_create_create_should_define_interface_with_success_status" {
    # Test interface definition: execution succeeds, but no output (no impl)
    run command_user_create_create "john_doe" "john@example.com"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty output for interface
}

@test "command_user_create_validate_should_define_interface_with_success_status" {
    # Test interface definition for validation
    invalid_command='{"invalid":"structure"}'

    run command_user_create_validate "$invalid_command"
    [ "$status" -eq 0 ]  # For now, success on call; adjust to 1 post-impl
    [ -z "$output" ]
}

@test "command_user_create_get_username_should_define_interface_with_success_status" {
    # Create test command (mock) - but interface returns empty
    command='{"username":"john_doe","email":"john@example.com"}'

    # Test interface: execution succeeds, empty output
    run command_user_create_get_username "$command"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface; full impl later
}
