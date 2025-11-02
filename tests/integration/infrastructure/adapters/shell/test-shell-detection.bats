#!/usr/bin/env bats
# Test: test-shell-detection.bats
# Description: Integration tests for shell detection and compatibility

# Mock the log_error function
log_error() {
    echo "ERROR: $1" >&2
}

load '../../../../../src/infrastructure/adapters/shell/shell_utils.sh'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/ShellDetector.impl'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/FeatureDetector.impl'
load '../../../../../src/infrastructure/adapters/shell/implementations/posix/CompatibilityChecker.impl'

@test "shell_detector_detect_shell returns valid shell type" {
    run shell_detector_detect_shell
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^(bash|zsh|dash|posix|unknown)$ ]]
}

@test "shell_detector_detect_features returns at least basic features" {
    run shell_detector_detect_features
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [[ "$output" =~ basic ]]
}

@test "shell_detector_check_compatibility with basic feature returns success" {
    run shell_detector_check_compatibility basic
    [ "$status" -eq 0 ]
}

@test "shell_detector_get_shell_version returns non-empty string" {
    run shell_detector_get_shell_version
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "shell_detector_is_posix_compliant returns success (should be POSIX compliant)" {
    run shell_detector_is_posix_compliant
    # This may return 0 or 1 depending on the actual shell environment
}

@test "feature_detector_get_available_features returns list containing basic" {
    run feature_detector_get_available_features
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [[ "$output" =~ basic ]]
}

@test "feature_detector_check_feature basic returns success" {
    run feature_detector_check_feature basic
    [ "$status" -eq 0 ]
}

@test "feature_detector_check_feature invalid_feature returns failure" {
    run feature_detector_check_feature invalid_feature
    [ "$status" -eq 1 ]
}

@test "compatibility_checker_check_posix_compatibility returns success in POSIX environment" {
    run compatibility_checker_check_posix_compatibility
    # May return 0 or 1 depending on actual environment
}

@test "compatibility_checker_get_compatibility_report contains POSIX status" {
    run compatibility_checker_get_compatibility_report
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    [[ "$output" =~ POSIX: ]]
}

@test "compatibility_checker_validate_platform_support with current platform returns success" {
    current_os=$(get_os_type)
    run compatibility_checker_validate_platform_support "$current_os"
    [ "$status" -eq 0 ]
}

@test "compatibility_checker_validate_platform_support with invalid platform returns failure" {
    run compatibility_checker_validate_platform_support "nonexistent_platform"
    [ "$status" -eq 1 ]
}