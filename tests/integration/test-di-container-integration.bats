#!/usr/bin/env bats

# Integration tests for full DI container
# Tests real-world scenarios with actual service implementations

setup() {
    # Setup test directory
    TEST_DIR="${BATS_TEST_TMPDIR}/di_integration_test"
    mkdir -p "$TEST_DIR"
    
    # Create mock service implementations
    
    # Logger.impl (no dependencies)
    cat > "$TEST_DIR/Logger.impl" << 'IMPL'
#!/bin/sh
# Mock Logger implementation

init_Logger() {
    _instance_id="$1"
    # _deps="$2" # No dependencies
    
    # Store instance state (in real impl, would use files or vars)
    printf "Logger initialized: %s\n" "$_instance_id" >&2
    return 0
}

logger_log() {
    _instance_id="$1"
    _message="$2"
    printf "[Logger %s] %s\n" "$_instance_id" "$_message"
}
IMPL
    
    # Database.impl (depends on Logger)
    cat > "$TEST_DIR/Database.impl" << 'IMPL'
#!/bin/sh
# Mock Database implementation

init_Database() {
    _instance_id="$1"
    _deps="$2" # Should be logger instance ID
    
    printf "Database initialized: %s (logger: %s)\n" "$_instance_id" "$_deps" >&2
    return 0
}

database_query() {
    _instance_id="$1"
    _query="$2"
    printf "[Database %s] Executing: %s\n" "$_instance_id" "$_query"
}
IMPL
    
    # UserService.impl (depends on Logger and Database)
    cat > "$TEST_DIR/UserService.impl" << 'IMPL'
#!/bin/sh
# Mock UserService implementation

init_UserService() {
    _instance_id="$1"
    _deps="$2" # Comma-separated: logger_id,database_id
    
    printf "UserService initialized: %s (deps: %s)\n" "$_instance_id" "$_deps" >&2
    return 0
}

user_service_get_user() {
    _instance_id="$1"
    _user_id="$2"
    printf "[UserService %s] Getting user: %s\n" "$_instance_id" "$_user_id"
}
IMPL
    
    # CircularA.impl (depends on CircularB)
    cat > "$TEST_DIR/CircularA.impl" << 'IMPL'
#!/bin/sh
init_CircularA() {
    _instance_id="$1"
    _deps="$2"
    return 0
}
IMPL
    
    # CircularB.impl (depends on CircularA) - creates circular dependency!
    cat > "$TEST_DIR/CircularB.impl" << 'IMPL'
#!/bin/sh
init_CircularB() {
    _instance_id="$1"
    _deps="$2"
    return 0
}
IMPL
    
    # Source DI Container
    . "${BATS_TEST_DIRNAME}/../../src/infrastructure/di/core/Container.interface"
    
    # Initialize container
    di_init
}

teardown() {
    # Cleanup
    di_dispose
    rm -rf "$TEST_DIR"
}

@test "Integration: Should register and resolve simple service" {
    # Register logger (no dependencies)
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "singleton"
    
    # Resolve
    logger=$(di_container_resolve "Logger.interface")
    
    # Verify
    [ -n "$logger" ]
    [[ "$logger" =~ ^instance_ ]]
}

@test "Integration: Should resolve service with dependencies" {
    # Register services
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "singleton"
    di_container_register_with_deps "Database.interface" "$TEST_DIR/Database.impl" "singleton" "Logger.interface"
    
    # Resolve database (should auto-resolve logger)
    database=$(di_container_resolve "Database.interface")
    
    # Verify
    [ -n "$database" ]
    [[ "$database" =~ ^instance_ ]]
}

@test "Integration: Should resolve complex dependency chain" {
    # Register chain: UserService -> Logger, Database; Database -> Logger
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "singleton"
    di_container_register_with_deps "Database.interface" "$TEST_DIR/Database.impl" "singleton" "Logger.interface"
    di_container_register_with_deps "UserService.interface" "$TEST_DIR/UserService.impl" "transient" "Logger.interface,Database.interface"
    
    # Resolve UserService (should auto-resolve entire chain)
    user_service=$(di_container_resolve "UserService.interface")
    
    # Verify
    [ -n "$user_service" ]
    [[ "$user_service" =~ ^instance_ ]]
}

@test "Integration: Should return same instance for singleton" {
    # Register as singleton
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "singleton"
    
    # Resolve twice
    logger1=$(di_container_resolve "Logger.interface")
    logger2=$(di_container_resolve "Logger.interface")
    
    # Should be same instance
    [ "$logger1" = "$logger2" ]
}

@test "Integration: Should return different instances for transient" {
    # Register as transient
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "transient"
    
    # Resolve twice
    logger1=$(di_container_resolve "Logger.interface")
    logger2=$(di_container_resolve "Logger.interface")
    
    # Should be different instances
    [ "$logger1" != "$logger2" ]
}

@test "Integration: Should detect circular dependencies" {
    # Register circular dependency: A -> B, B -> A
    di_container_register_with_deps "CircularA.interface" "$TEST_DIR/CircularA.impl" "transient" "CircularB.interface"
    di_container_register_with_deps "CircularB.interface" "$TEST_DIR/CircularB.impl" "transient" "CircularA.interface"
    
    # Try to resolve - should fail with circular dependency error
    run di_container_resolve "CircularA.interface"
    
    [ $status -ne 0 ]
    [[ "$output" =~ "Circular dependency" ]]
}

@test "Integration: Should provide accurate statistics" {
    # Register multiple services
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "singleton"
    di_container_register "Database.interface" "$TEST_DIR/Database.impl" "singleton"
    di_container_register "UserService.interface" "$TEST_DIR/UserService.impl" "transient"
    
    # Resolve singletons to cache them
    di_container_resolve "Logger.interface" >/dev/null
    di_container_resolve "Database.interface" >/dev/null
    
    # Get stats
    stats=$(di_container_stats)
    
    # Verify
    [[ "$stats" =~ "Registered services: 3" ]]
    [[ "$stats" =~ "Cached singletons:   2" ]]
}

@test "Integration: Should clear singleton cache" {
    # Register and resolve singleton
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "singleton"
    logger1=$(di_container_resolve "Logger.interface")
    
    # Clear cache
    di_container_clear_cache
    
    # Resolve again - should get NEW instance
    logger2=$(di_container_resolve "Logger.interface")
    
    # Should be different (cache was cleared)
    [ "$logger1" != "$logger2" ]
}

@test "Integration: Should reset entire container" {
    # Register services
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "singleton"
    di_container_register "Database.interface" "$TEST_DIR/Database.impl" "singleton"
    
    # Reset
    di_container_reset
    
    # Should no longer be registered
    di_container_has "Logger.interface"
    [ $? -ne 0 ]
    
    di_container_has "Database.interface"
    [ $? -ne 0 ]
}

@test "Integration: Should handle missing implementation gracefully" {
    # Register service with non-existent implementation
    di_container_register "Missing.interface" "/nonexistent/Missing.impl" "singleton"
    
    # Try to resolve - should fail gracefully
    run di_container_resolve "Missing.interface"
    
    [ $status -ne 0 ]
    [[ "$output" =~ "not found" ]]
}

@test "Integration: Should list all registered services" {
    # Register multiple services
    di_container_register "Logger.interface" "$TEST_DIR/Logger.impl" "singleton"
    di_container_register "Database.interface" "$TEST_DIR/Database.impl" "singleton"
    di_container_register "UserService.interface" "$TEST_DIR/UserService.impl" "transient"
    
    # List all
    services=$(di_container_list)
    
    # Verify all are listed
    echo "$services" | grep -q "Logger.interface"
    echo "$services" | grep -q "Database.interface"
    echo "$services" | grep -q "UserService.interface"
}
