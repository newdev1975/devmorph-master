#!/usr/bin/env bats

# Integration tests for the main CLI functionality

@test "devmorph CLI - basic help" {
  run /home/robert/dev/devmorph-master/devmorph --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
  [[ "$output" =~ "workspace" ]]
}

@test "devmorph CLI - workspace help" {
  run /home/robert/dev/devmorph-master/devmorph workspace --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
  [[ "$output" =~ "create" ]]
  [[ "$output" =~ "start" ]]
  [[ "$output" =~ "stop" ]]
  [[ "$output" =~ "list" ]]
  [[ "$output" =~ "destroy" ]]
  [[ "$output" =~ "mode" ]]
}

@test "devmorph CLI - unknown command" {
  run /home/robert/dev/devmorph-master/devmorph nonexistent
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unknown" ]]
}

@test "devmorph CLI - unknown workspace command" {
  run /home/robert/dev/devmorph-master/devmorph workspace nonexistent
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unknown workspace command" ]]
}

@test "devmorph CLI - workspace list (should work if in right directory)" {
  run /home/robert/dev/devmorph-master/devmorph workspace list
  [ "$status" -eq 0 ]
  # When there are no workspaces, it should still succeed
}