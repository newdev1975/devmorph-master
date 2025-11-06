#!/usr/bin/env bats

setup() {
    export DI_SINGLETON_CACHE="${BATS_TEST_TMPDIR}/di_singletons_$$"
    . "${BATS_TEST_DIRNAME}/../../../src/infrastructure/di/lifecycle/LifetimeManager.interface"
}

teardown() {
    rm -f "$DI_SINGLETON_CACHE"
}

@test "Should cache singleton instances (POSIX)" {
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
    
    # FIX: Explicitly check for non-zero return
    if di_has_singleton "NonExistent.interface"; then
        return 1  # Should NOT be cached
    fi
}

@test "Should clear singleton cache (POSIX)" {
    di_cache_singleton "Logger.interface" "logger_instance_123"
    
    di_clear_singletons
    
    # FIX: Explicitly check for non-zero return
    if di_has_singleton "Logger.interface"; then
        return 1  # Should NOT be cached after clear
    fi
}
