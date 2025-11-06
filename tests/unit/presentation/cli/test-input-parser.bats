#!/usr/bin/env bats

setup() {
    source src/presentation/cli/InputParser.interface
}

@test "cli_parser_create_should_define_interface_with_success_status" {
    # Test interface definition: execution succeeds, but no output (no impl)
    run cli_parser_create "{}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty output for interface
}

@test "cli_parser_parse_should_define_interface_with_success_status" {
    # Create parser (mock identifier)
    parser_id="test_parser"

    # Test interface: execution succeeds, empty output
    run cli_parser_parse "$parser_id" '["--name", "test", "--value", "123"]'
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Expect empty for interface; full impl later
}
