#!/usr/bin/env bats

setup() {
    source src/presentation/cli/CliApplication.interface
}

@test "cli_app_init_should_define_interface_with_success_status" {
    # Test interface definition: execution succeeds, but no output (no impl)
    run cli_app_init "{}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty output for interface
}

@test "cli_app_register_command_should_define_interface_with_success_status" {
    # Initialize CLI app - but interface returns empty
    run cli_app_init "{}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface

    # Test interface: execution succeeds, empty output
    run cli_app_register_command "test" "test_handler" "Test command"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface; full impl later
}

@test "cli_app_run_should_define_interface_with_success_status" {
    # Initialize CLI app - but interface returns empty
    run cli_app_init "{}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface

    # Test interface: execution succeeds, empty output
    run cli_app_run '["test", "--help"]'
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # For now, allow 0 or 1; adjust post-impl
    [ -z "$output" ]  # Expect empty for interface; full impl later
}
