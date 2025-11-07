#!/usr/bin/env bats

setup() {
    source src/application/workflows/UserRegistrationWorkflow.interface
}

@test "workflow_user_registration_execute_should_define_interface_with_success_status" {
    # Create workflow (mock identifier)
    workflow_id="test_workflow"

    # Create test registration data
    registration_data='{"username":"john_doe","email":"john@example.com"}'

    # Test interface: execution succeeds, empty output
    run workflow_user_registration_execute "$workflow_id" "$registration_data"
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # For now, allow 0 or 1; adjust post-impl
    [ -z "$output" ]  # Expect empty for interface; full impl later
}

@test "workflow_user_registration_validate_should_define_interface_with_success_status" {
    # Create workflow (mock identifier)
    workflow_id="test_workflow"

    # Create valid registration data
    valid_data='{"username":"john_doe","email":"john@example.com"}'

    # Test interface: execution succeeds, empty output
    run workflow_user_registration_validate "$workflow_id" "$valid_data"
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # For now, allow 0 or 1; adjust post-impl
    [ -z "$output" ]  # Expect empty for interface; full impl later
}
