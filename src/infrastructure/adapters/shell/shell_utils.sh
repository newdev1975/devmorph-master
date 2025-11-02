#!/bin/sh
# Utility: shell_utils.sh
# Description: Common shell utilities for the abstraction layer

# Description: Log an error message
# Parameters:
#   $1 - Error message
# Returns:
#   0 - Always returns 0
log_error() {
    echo "ERROR: $1" >&2
    return 0
}

# Description: Log an info message
# Parameters:
#   $1 - Info message
# Returns:
#   0 - Always returns 0
log_info() {
    echo "INFO: $1" >&1
    return 0
}

# Description: Check if a command exists
# Parameters:
#   $1 - Command name
# Returns:
#   0 - Command exists
#   1 - Command does not exist
command_exists() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Description: Get the current operating system type
# Parameters: None
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes the OS type (linux, darwin, windows, freebsd, unknown)
get_os_type() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "darwin" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        FreeBSD*)   echo "freebsd" ;;
        *)          echo "unknown" ;;
    esac
}

# Description: Get the current shell type
# Parameters: None
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes the shell type (bash, zsh, dash, posix, unknown)
get_shell_type() {
    if [ -n "${BASH_VERSION}" ]; then
        echo "bash"
    elif [ -n "${ZSH_VERSION}" ]; then
        echo "zsh"
    elif [ -n "${DASH_VERSION}" ]; then
        echo "dash"
    else
        echo "posix"
    fi
}

# Description: Normalize path for the current platform
# Parameters:
#   $1 - Path to normalize
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes the normalized path
normalize_path() {
    case "$(get_os_type)" in
        "windows")
            echo "$1" | sed 's|/|\\|g'
            ;;
        *)
            echo "$1" | sed 's|\\|/|g'
            ;;
    esac
}

# Description: Safe execution of a command with error handling
# Parameters:
#   $@ - Command and arguments
# Returns:
#   0 - Command executed successfully
#   1 - Command failed
safe_execute() {
    if "$@"; then
        return 0
    else
        log_error "Command failed: $*"
        return 1
    fi
}

# Description: Check if a file or directory exists
# Parameters:
#   $1 - Path to check
# Returns:
#   0 - Path exists
#   1 - Path does not exist
path_exists() {
    if [ -e "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Description: Check if a path is a directory
# Parameters:
#   $1 - Path to check
# Returns:
#   0 - Path is a directory
#   1 - Path is not a directory
is_directory() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Description: Check if a path is a file
# Parameters:
#   $1 - Path to check
# Returns:
#   0 - Path is a file
#   1 - Path is not a file
is_file() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Description: Get current process ID
# Parameters: None
# Returns:
#   0 - Always returns 0
# Output:
#   Echoes the current process ID
get_current_pid() {
    echo $$  # POSIX compliant way to get current PID
}