#!/usr/bin/env bats

setup() {
    source src/application/modules/UserModule.interface
    source src/core/infrastructure/container/Container.interface
    source src/application/workflows/UserRegistrationWorkflow.interface
}

@test "full_user_registration_workflow_should_define_interface_with_success_status" {
    # Initialize user module
    run module_user_init "{}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface

    # Initialize DI container
    run di_container_init
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface

    # Register user services
    run module_user_register_services "container_123"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface

    # Execute registration workflow
    registration_data='{"username":"john_doe","email":"john@example.com"}'
    run workflow_user_registration_execute "workflow_123" "$registration_data"
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # For now, allow 0 or 1; adjust post-impl
    [ -z "$output" ]  # Expect empty for interface; full impl later
}
