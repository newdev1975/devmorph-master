#!/usr/bin/env bats

setup() {
    source src/infrastructure/adapters/shell/ShellAdapter.interface
}

@test "adapter_shell_create_should_define_interface_with_success_status" {
    # Test interface definition: execution succeeds, but no output (no impl)
    run adapter_shell_create "{}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty output for interface
}

@test "adapter_shell_execute_should_define_interface_with_success_status" {
    # Create test adapter (mock identifier)
    adapter_id="test_adapter"

    # Test interface: execution succeeds, empty output
    run adapter_shell_execute "$adapter_id" "echo test"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface; full impl later
}
