#!/usr/bin/env bats

setup() {
    export DI_SINGLETON_CACHE="${BATS_TEST_TMPDIR}/di_singletons_$$"
    . "${BATS_TEST_DIRNAME}/../../../src/infrastructure/di/lifecycle/LifetimeManager.interface"
}

teardown() {
    rm -f "$DI_SINGLETON_CACHE"
}

@test "Should cache singleton instances (POSIX)" {
    # Simulate instance creation
    di_cache_singleton "Logger.interface" "logger_instance_123"
    
    [ $? -eq 0 ]
}

@test "Should retrieve cached singleton (POSIX)" {
    di_cache_singleton "Logger.interface" "logger_instance_123"
    
    instance=$(di_get_singleton "Logger.interface")
    [ "$instance" = "logger_instance_123" ]
}

@test "Should check if singleton cached (POSIX)" {
    di_cache_singleton "Logger.interface" "logger_instance_123"
    
    di_has_singleton "Logger.interface"
    [ $? -eq 0 ]
    
    di_has_singleton "NonExistent.interface"
    [ $? -ne 0 ]
}

@test "Should clear singleton cache (POSIX)" {
    di_cache_singleton "Logger.interface" "logger_instance_123"
    
    di_clear_singletons
    
    di_has_singleton "Logger.interface"
    [ $? -ne 0 ]
}
