#!/usr/bin/env bats

@test "debug paths" {
    echo "BATS_TEST_FILENAME: $BATS_TEST_FILENAME" >&3
    echo "BATS_TEST_DIRNAME: $BATS_TEST_DIRNAME" >&3
    echo "BATS_VERSION: $BATS_VERSION" >&3
    echo "PWD: $(pwd)" >&3
    echo "Looking for hardware-detector.sh at: $(pwd)/../lib/hardware-detector.sh" >&3
    echo "File exists: $(if [ -f ../lib/hardware-detector.sh ]; then echo 'YES'; else echo 'NO'; fi)" >&3
    ls -la ../lib/ >&3
    [ true ]
}