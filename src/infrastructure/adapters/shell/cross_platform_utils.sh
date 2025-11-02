#!/bin/sh
# Utility: cross_platform_utils.sh
# Description: Cross-platform utilities and path handling

# Description: Get the current operating system type
# Parameters: None
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes the OS type (linux, darwin, windows, freebsd, unknown)
get_platform_type() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "darwin" ;;
        CYGWIN*|MINGW*|MSYS*|Windows*) echo "windows" ;;
        FreeBSD*)   echo "freebsd" ;;
        *)          echo "unknown" ;;
    esac
}

# Description: Normalize path for the current platform
# Parameters:
#   $1 - Path to normalize
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes the normalized path
normalize_path() {
    case "$(get_platform_type)" in
        "windows")
            # Convert to Windows path format if needed
            echo "$1" | sed 's|/|\\\\|g'
            ;;
        *)
            # Use standard Unix path format
            echo "$1" | sed 's|\\\\|/|g'
            ;;
    esac
}

# Description: Convert to Windows-style path
# Parameters:
#   $1 - Path to convert
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes Windows-style path
to_windows_path() {
    echo "$1" | sed 's|/|\\|g'
}

# Description: Convert to Unix-style path
# Parameters:
#   $1 - Path to convert
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes Unix-style path
to_unix_path() {
    echo "$1" | sed 's|\\|/|g'
}

# Description: Check if running on Windows platform
# Parameters: None
# Returns:
#   0 - Running on Windows
#   1 - Not running on Windows
is_windows_platform() {
    if [ "$(get_platform_type)" = "windows" ]; then
        return 0
    else
        return 1
    fi
}

# Description: Check if running on Unix-like platform
# Parameters: None
# Returns:
#   0 - Running on Unix-like
#   1 - Not running on Unix-like
is_unix_platform() {
    platform=$(get_platform_type)
    if [ "$platform" = "linux" ] || [ "$platform" = "darwin" ] || [ "$platform" = "freebsd" ]; then
        return 0
    else
        return 1
    fi
}

# Description: Get appropriate path separator for the current platform
# Parameters: None
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes the path separator
get_path_separator() {
    if is_windows_platform; then
        echo "\\"
    else
        echo "/"
    fi
}

# Description: Convert Windows paths to WSL/Linux format when appropriate
# Parameters:
#   $1 - Path to convert
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes converted path
wsl_path_conversion() {
    if [ "$(get_platform_type)" = "linux" ] && command -v wslpath >/dev/null 2>&1; then
        # If we're in WSL, convert Windows paths
        wslpath -u "$1" 2>/dev/null || echo "$1"
    else
        # Not in WSL, return path as is
        echo "$1"
    fi
}