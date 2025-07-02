#!/bin/sh
# Test runner for DevMorph AI Studio Workspace Manager

# Exit on error
set -e

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "  -t, --test <test-file>  Run specific test file"
    echo "  -a, --all             Run all tests (default)"
    echo "  -u, --unit            Run only unit tests"
    echo "  -i, --integration     Run only integration tests"
    echo "  -h, --help            Display this help message"
    exit 0
}

# Default values
RUN_ALL=true
RUN_UNIT=false
RUN_INTEGRATION=false
SPECIFIC_TEST=""

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -t|--test)
            if [ -n "$2" ]; then
                SPECIFIC_TEST="$2"
                RUN_ALL=false
                shift 2
            else
                echo "Error: --test requires an argument" >&2
                exit 1
            fi
            ;;
        -a|--all)
            RUN_ALL=true
            RUN_UNIT=false
            RUN_INTEGRATION=false
            shift
            ;;
        -u|--unit)
            RUN_UNIT=true
            RUN_INTEGRATION=false
            RUN_ALL=false
            shift
            ;;
        -i|--integration)
            RUN_INTEGRATION=true
            RUN_UNIT=false
            RUN_ALL=false
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

echo "DevMorph AI Studio - Workspace Manager Tests"
echo "============================================="

# Check if bats is installed
if ! command -v bats >/dev/null 2>&1; then
    echo "Error: bats (Bash Automated Testing System) is not installed" >&2
    echo "Please install bats to run tests: https://github.com/bats-core/bats-core" >&2
    exit 1
fi

# Run specific test if provided
if [ -n "$SPECIFIC_TEST" ]; then
    if [ -f "$SPECIFIC_TEST" ]; then
        echo "Running specific test: $SPECIFIC_TEST"
        bats "$SPECIFIC_TEST"
    else
        echo "Error: Test file does not exist: $SPECIFIC_TEST" >&2
        exit 1
    fi
    exit 0
fi

# Determine which tests to run
if $RUN_ALL; then
    echo "Running all tests..."
    # Run unit tests first
    if [ -d "tests/unit" ] && [ -n "$(ls -A tests/unit/*.bats 2>/dev/null)" ]; then
        echo "Running unit tests..."
        bats tests/unit/*.bats
    else
        echo "No unit tests found"
    fi
    
    # Run integration tests
    if [ -d "tests/integration" ] && [ -n "$(ls -A tests/integration/*.bats 2>/dev/null)" ]; then
        echo "Running integration tests..."
        bats tests/integration/*.bats
    else
        echo "No integration tests found"
    fi
elif $RUN_UNIT; then
    echo "Running unit tests..."
    if [ -d "tests/unit" ] && [ -n "$(ls -A tests/unit/*.bats 2>/dev/null)" ]; then
        bats tests/unit/*.bats
    else
        echo "No unit tests found"
    fi
elif $RUN_INTEGRATION; then
    echo "Running integration tests..."
    if [ -d "tests/integration" ] && [ -n "$(ls -A tests/integration/*.bats 2>/dev/null)" ]; then
        bats tests/integration/*.bats
    else
        echo "No integration tests found"
    fi
else
    echo "Running all tests by default..."
    if [ -d "tests/unit" ] && [ -n "$(ls -A tests/unit/*.bats 2>/dev/null)" ]; then
        bats tests/unit/*.bats
    fi
    if [ -d "tests/integration" ] && [ -n "$(ls -A tests/integration/*.bats 2>/dev/null)" ]; then
        bats tests/integration/*.bats
    fi
fi

echo ""
echo "Tests completed!"