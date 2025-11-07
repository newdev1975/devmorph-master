#!/usr/bin/env bats

setup() {
    source src/core/domain/models/Workspace.interface
}

@test "entity_workspace_create_should_define_interface_with_success_status" {
    # Test interface definition: execution succeeds, but no output (no impl)
    run entity_workspace_create "workspace_123" "My Workspace" "user_456"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty output for interface
}

@test "entity_workspace_validate_should_define_interface_with_success_status" {
    # Test interface definition for validation
    invalid_entity='{"invalid":"structure"}'

    run entity_workspace_validate "$invalid_entity"
    [ "$status" -eq 0 ]  # For now, success on call; adjust to 1 post-impl
    [ -z "$output" ]
}
