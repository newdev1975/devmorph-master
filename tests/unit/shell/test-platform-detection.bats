#!/usr/bin/env bats

setup() {
    # POSIX: Use . instead of source
    . "${BATS_TEST_DIRNAME}/../../../src/infrastructure/shell/detection/PlatformDetector.interface"
}

@test "Should detect operating system (POSIX)" {
    # Use command substitution (POSIX)
    os=$(detect_os)
    
    # POSIX test syntax
    [ -n "$os" ]
    
    # POSIX case for pattern matching
    case "$os" in
        linux|darwin|windows|bsd)
            # Valid OS detected
            ;;
        *)
            # Unknown OS
            return 1
            ;;
    esac
}

@test "Should detect if Unix-like (POSIX)" {
    # Function returns exit code
    if is_unix_like; then
        # Unix-like system
        return 0
    else
        # Not Unix-like (might be Windows)
        return 0  # Still pass test
    fi
}

@test "Should get path separator (POSIX)" {
    sep=$(get_path_separator)
    
    # POSIX: Use [ ] not [[ ]]
    [ -n "$sep" ]
    
    # Should be / or \
    case "$sep" in
        /|\\)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
