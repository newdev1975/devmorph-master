#!/usr/bin/env bats

setup() {
    . "${BATS_TEST_DIRNAME}/../../../src/infrastructure/shell/operations/StringOperations.interface"
}

@test "Should trim whitespace (POSIX)" {
    result=$(string_trim "  hello world  ")
    [ "$result" = "hello world" ]
    
    result=$(string_trim "	text	")
    [ "$result" = "text" ]
}

@test "Should convert to uppercase (POSIX)" {
    result=$(string_to_upper "hello")
    [ "$result" = "HELLO" ]
    
    result=$(string_to_upper "Hello World")
    [ "$result" = "HELLO WORLD" ]
}

@test "Should convert to lowercase (POSIX)" {
    result=$(string_to_lower "HELLO")
    [ "$result" = "hello" ]
    
    result=$(string_to_lower "Hello World")
    [ "$result" = "hello world" ]
}

@test "Should check if contains substring (POSIX)" {
    string_contains "hello world" "world"
    [ $? -eq 0 ]
    
    string_contains "hello world" "foo"
    [ $? -ne 0 ]
}

@test "Should check if starts with prefix (POSIX)" {
    string_starts_with "hello world" "hello"
    [ $? -eq 0 ]
    
    string_starts_with "hello world" "world"
    [ $? -ne 0 ]
}

@test "Should check if ends with suffix (POSIX)" {
    string_ends_with "hello world" "world"
    [ $? -eq 0 ]
    
    string_ends_with "hello world" "hello"
    [ $? -ne 0 ]
}

@test "Should get string length (POSIX)" {
    result=$(string_length "hello")
    [ "$result" = "5" ]
    
    result=$(string_length "")
    [ "$result" = "0" ]
}

@test "Should extract substring (POSIX)" {
    result=$(string_substring "hello world" 1 5)
    [ "$result" = "hello" ]
    
    result=$(string_substring "hello world" 7)
    [ "$result" = "world" ]
}

@test "Should replace string (POSIX)" {
    result=$(string_replace_first "hello hello" "hello" "hi")
    [ "$result" = "hi hello" ]
    
    result=$(string_replace_all "hello hello" "hello" "hi")
    [ "$result" = "hi hi" ]
}

@test "Should split string (POSIX)" {
    result=$(string_split "a,b,c" ",")
    expected="a
b
c"
    [ "$result" = "$expected" ]
}

@test "Should join strings (POSIX)" {
    result=$(printf "a\nb\nc\n" | string_join ",")
    [ "$result" = "a,b,c" ]
}

@test "Should check if empty (POSIX)" {
    string_is_empty ""
    [ $? -eq 0 ]
    
    string_is_empty "   "
    [ $? -eq 0 ]
    
    string_is_empty "text"
    [ $? -ne 0 ]
}

@test "Should repeat string (POSIX)" {
    result=$(string_repeat "x" 3)
    [ "$result" = "xxx" ]
    
    result=$(string_repeat "ab" 2)
    [ "$result" = "abab" ]
}
