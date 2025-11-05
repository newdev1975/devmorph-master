#!/usr/bin/env bats

setup() {
    # Source DI components (will be created)
    export DI_REGISTRY_FILE="${BATS_TEST_TMPDIR}/di_registry_$$"
    . "${BATS_TEST_DIRNAME}/../../../src/infrastructure/di/registry/ServiceRegistry.interface"
}

teardown() {
    # Cleanup
    rm -f "$DI_REGISTRY_FILE"
}

@test "Should register service (POSIX)" {
    di_register "Logger.interface" "Logger.impl" "singleton" ""
    
    # Check registration succeeded
    [ $? -eq 0 ]
    
    # Verify registry file exists
    [ -f "$DI_REGISTRY_FILE" ]
}

@test "Should check if service is registered (POSIX)" {
    di_register "Logger.interface" "Logger.impl" "singleton" ""
    
    di_is_registered "Logger.interface"
    [ $? -eq 0 ]
    
    di_is_registered "NonExistent.interface"
    [ $? -ne 0 ]
}

@test "Should get service info (POSIX)" {
    di_register "Logger.interface" "Logger.impl" "transient" "Config.interface"
    
    impl=$(di_get_implementation "Logger.interface")
    [ "$impl" = "Logger.impl" ]
    
    lifetime=$(di_get_lifetime "Logger.interface")
    [ "$lifetime" = "transient" ]
}

@test "Should handle dependencies (POSIX)" {
    di_register "Logger.interface" "Logger.impl" "singleton" ""
    di_register "Database.interface" "Database.impl" "singleton" "Logger.interface"
    
    deps=$(di_get_dependencies "Database.interface")
    [ "$deps" = "Logger.interface" ]
}

@test "Should clear registry (POSIX)" {
    di_register "Logger.interface" "Logger.impl" "singleton" ""
    
    di_clear_registry
    
    di_is_registered "Logger.interface"
    [ $? -ne 0 ]
}
