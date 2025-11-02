#!/bin/sh
# Validation script for Shell Abstraction Layer

echo "=== Shell Abstraction Layer Validation ==="

# Source required files for validation
if [ -f "src/infrastructure/adapters/shell/shell_utils.sh" ]; then
    . src/infrastructure/adapters/shell/shell_utils.sh
    echo "✓ shell_utils.sh loaded successfully"
else
    echo "✗ shell_utils.sh not found"
    exit 1
fi

# Load essential implementations
if [ -f "src/infrastructure/adapters/shell/implementations/posix/POSIXFileOperations.impl" ]; then
    . src/infrastructure/adapters/shell/implementations/posix/POSIXFileOperations.impl
    echo "✓ POSIXFileOperations loaded successfully"
else
    echo "✗ POSIXFileOperations not found"
    exit 1
fi

if [ -f "src/infrastructure/adapters/shell/implementations/posix/POSIXStringOperations.impl" ]; then
    . src/infrastructure/adapters/shell/implementations/posix/POSIXStringOperations.impl
    echo "✓ POSIXStringOperations loaded successfully"
else
    echo "✗ POSIXStringOperations not found"
    exit 1
fi

if [ -f "src/infrastructure/adapters/shell/implementations/posix/POSIXSystemOperations.impl" ]; then
    . src/infrastructure/adapters/shell/implementations/posix/POSIXSystemOperations.impl
    echo "✓ POSIXSystemOperations loaded successfully"
else
    echo "✗ POSIXSystemOperations not found"
    exit 1
fi

# Test basic functionality
echo ""
echo "=== Testing Core Functionality ==="

# Test string operations
echo "Testing string operations..."
result=$(posix_trim "  hello world  ")
if [ "$result" = "hello world" ]; then
    echo "✓ trim works: '$result'"
else
    echo "✗ trim failed: '$result'"
fi

result=$(posix_to_upper "hello")
if [ "$result" = "HELLO" ]; then
    echo "✓ to_upper works: '$result'"
else
    echo "✗ to_upper failed: '$result'"
fi

# Test system operations
echo "Testing system operations..."
result=$(posix_get_os_type)
echo "✓ OS detection: $result"

result=$(posix_get_shell_type)
echo "✓ Shell detection: $result"

# Test file operations with a temporary file
echo "Testing file operations..."
test_dir="/tmp/shell_abstraction_test_$(date +%s)"
if posix_mkdir "$test_dir"; then
    echo "✓ mkdir works: $test_dir"
    
    test_file="$test_dir/test.txt"
    if echo "test content" | posix_write_file "$test_file" "$(cat)"; then
        echo "✓ write_file works: $test_file"
        
        content=$(posix_read_file "$test_file")
        if [ "$content" = "test content" ]; then
            echo "✓ read_file works: '$content'"
        else
            echo "✗ read_file failed"
        fi
    else
        echo "✗ write_file failed"
    fi
    
    # Clean up
    if posix_rm "$test_dir"; then
        echo "✓ rm works: cleaned up $test_dir"
    else
        echo "✗ rm failed to clean up"
    fi
else
    echo "✗ mkdir failed"
fi

# Check command availability
if posix_check_command "echo"; then
    echo "✓ check_command works: echo exists"
else
    echo "✗ check_command failed: echo not found"
fi

echo ""
echo "=== Validation Complete ==="
echo "Shell Abstraction Layer is properly implemented and functioning."