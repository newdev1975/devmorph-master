#!/bin/sh
# Helpers Library for DevMorph AI Studio
# Provides common utility functions

# Exit on error
set -e

# Function to check if a command exists
# Arguments:
# $1 - Command name
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get the directory of the current script
get_script_dir() {
    CDPATH= cd -- "$(dirname -- "$0")" && pwd -P
}

# Function to create a temporary file with proper cleanup
# Arguments:
# $1 - Prefix for the temp file
create_temp_file() {
    prefix="$1"
    
    if command_exists mktemp; then
        mktemp --tmpdir "$prefix.XXXXXX"
    else
        # Fallback for systems without mktemp
        tmp_dir="${TMPDIR:-/tmp}"
        temp_file="$tmp_dir/${prefix}.$$"
        touch "$temp_file"
        echo "$temp_file"
    fi
}

# Function to cleanup temporary files on exit
# Arguments:
# $@ - List of files to delete
cleanup_temp_files() {
    for file in "$@"; do
        if [ -f "$file" ]; then
            rm -f "$file" 2>/dev/null || true
        fi
    done
}

# Function to check if running on Linux
is_linux() {
    case "$(uname -s)" in
        Linux*)   return 0 ;;
        *)        return 1 ;;
    esac
}

# Function to check if running on macOS
is_macos() {
    case "$(uname -s)" in
        Darwin*)  return 0 ;;
        *)        return 1 ;;
    esac
}

# Function to check if running on Windows (WSL/Cygwin)
is_windows() {
    case "$(uname -s)" in
        *MINGW*|*CYGWIN*|*MSYS*) return 0 ;;
        *) 
            # Check if in WSL
            if [ -e /proc/version ] && grep -qi microsoft /proc/version; then
                return 0
            fi
            return 1
            ;;
    esac
}

# Function to get the OS name
get_os() {
    if is_linux; then
        echo "linux"
    elif is_macos; then
        echo "macos"
    elif is_windows; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to check if Docker is available
is_docker_available() {
    if command_exists docker && docker info >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if Docker Compose is available
is_docker_compose_available() {
    if command_exists docker-compose || (command_exists docker && docker compose version >/dev/null 2>&1); then
        return 0
    else
        return 1
    fi
}

# Function to wait for a port to be available
# Arguments:
# $1 - Port number
# $2 - Timeout in seconds (default: 30)
wait_for_port() {
    port="$1"
    timeout="${2:-30}"
    count=0
    
    while [ $count -lt $timeout ]; do
        if ! (exec 3<>/dev/tcp/127.0.0.1/$port) 2>/dev/null; then
            # Port is not available yet, continue waiting
            sleep 1
            count=$((count + 1))
        else
            # Close the connection if opened
            exec 3<&- 3>&- 2>/dev/null || true
            return 0  # Port is available
        fi
    done
    
    return 1  # Timeout reached
}

# Function to convert string to lowercase
# Arguments:
# $1 - String to convert
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Function to check if a file contains a string
# Arguments:
# $1 - File path
# $2 - String to search for
file_contains_string() {
    file_path="$1"
    search_string="$2"
    
    if [ ! -f "$file_path" ]; then
        return 1
    fi
    
    grep -qF "$search_string" "$file_path"
}

# Function to get the absolute path of a directory
# Arguments:
# $1 - Path to convert
get_absolute_path() {
    if [ -d "$1" ]; then
        (CDPATH= cd -- "$1" && pwd -P)
    elif [ -f "$1" ]; then
        (CDPATH= cd -- "$(dirname -- "$1")" && pwd -P)/$(basename -- "$1")
    else
        (CDPATH= cd -- "$(dirname -- "$1")" && pwd -P)/$(basename -- "$1")
    fi
}

# Function to safely copy files with error handling
# Arguments:
# $1 - Source path
# $2 - Destination path
safe_copy() {
    src="$1"
    dst="$2"
    
    # Validate source exists
    if [ ! -e "$src" ]; then
        echo "Error: Source does not exist: $src" >&2
        return 1
    fi
    
    # Use safer copy method to prevent path traversal
    if [ -d "$src" ]; then
        # Copy directory contents
        if ! (cd "$src" && tar cf - .) | (cd "$dst" && tar xf -); then
            echo "Error: Failed to copy directory from '$src' to '$dst'" >&2
            return 1
        fi
    else
        # Copy file
        if ! cp "$src" "$dst"; then
            echo "Error: Failed to copy file from '$src' to '$dst'" >&2
            return 1
        fi
    fi
    
    return 0
}

# Function to validate workspace path to prevent directory traversal
# Arguments:
# $1 - Path to validate
validate_workspace_path() {
    path="$1"
    
    # Check for dangerous patterns that could lead to directory traversal
    case "$path" in
        */..|*../|*../*|/*|../*|*//*)
            echo "Error: Path contains dangerous traversal patterns" >&2
            return 1
            ;;
    esac
    
    # Resolve the path and make sure it's under the current directory
    abs_path=$(get_absolute_path "$path")
    current_dir=$(get_absolute_path ".")
    
    case "$abs_path" in
        "$current_dir"/*|"$current_dir")
            # Path is within current directory, which is safe
            return 0
            ;;
        *)
            # Path is outside current directory, which is dangerous
            echo "Error: Path '$path' resolves outside current directory" >&2
            return 1
            ;;
    esac
}

# Function to escape special characters in strings for use with sed
# Arguments:
# $1 - String to escape
escape_for_sed() {
    echo "$1" | sed 's/[[\.*^$()+?{|]/\\&/g'
}