# POSIX Compliance Guide

## Overview
DevMorph uses POSIX sh as baseline for maximum cross-platform compatibility.

## POSIX vs Bashisms

### String Operations
```sh
# ❌ BASHISM
${var^^}        # Uppercase
${var,,}        # Lowercase
${var:0:5}      # Substring

# ✅ POSIX
echo "$var" | tr '[:lower:]' '[:upper:]'
echo "$var" | tr '[:upper:]' '[:lower:]'
echo "$var" | cut -c1-5
```

### Arithmetic
```sh
# ❌ BASHISM
((count++))
result=$((var1 + var2))

# ✅ POSIX
count=$(expr "$count" + 1)
result=$(expr "$var1" + "$var2")
# OR
result=$(awk "BEGIN {print $var1 + $var2}")
```

### Test Conditions
```sh
# ❌ BASHISM
[[ -n "$var" ]]
[[ "$a" == "$b" ]]
[[ "$a" =~ regex ]]

# ✅ POSIX
[ -n "$var" ]
[ "$a" = "$b" ]
echo "$a" | grep -qE "regex"
```

### Arrays
```sh
# ❌ BASHISM
array=("one" "two" "three")
echo "${array[0]}"

# ✅ POSIX (use positional parameters)
set -- "one" "two" "three"
echo "$1"

# ✅ POSIX (or use while loop with file)
while IFS= read -r line; do
    # process line
done < file
```

### Functions
```sh
# ❌ BASHISM
function myfunc() {
    local var="value"
    echo "$var"
}

# ✅ POSIX
myfunc() {
    # Note: 'local' is not POSIX, use careful naming
    _myfunc_var="value"
    echo "$_myfunc_var"
    unset _myfunc_var
}
```

### File Sourcing
```sh
# ❌ BASHISM
source ./file.sh

# ✅ POSIX
. ./file.sh
```

### Command Substitution
```sh
# ❌ OLD STYLE (avoid nested)
result=`command`

# ✅ POSIX (preferred)
result=$(command)
result=$(command1 $(command2))  # Can nest
```

## Testing POSIX Compliance

### Test with dash
```sh
# Dash is strictest POSIX shell
dash script.sh

# Set sh to dash for testing
sudo ln -sf /bin/dash /bin/sh
```

### Use checkbashisms
```sh
# Install
sudo apt install devscripts

# Check file
checkbashisms script.sh

# Check directory
find src -name "*.sh" -exec checkbashisms {} \;
```

### ShellCheck with POSIX
```sh
# Use ShellCheck in POSIX mode
shellcheck --shell=sh script.sh
```

## POSIX-Safe Patterns

### Safe Variable Expansion
```sh
# Always quote variables
"$var"          # ✅ GOOD
$var            # ❌ BAD (word splitting)

# Safe defaults
"${var:-default}"
"${var:=default}"
"${var:?error message}"
```

### Safe Loops
```sh
# ✅ GOOD - While with read
while IFS= read -r line; do
    echo "$line"
done < file

# ✅ GOOD - For with glob
for file in *.txt; do
    [ -e "$file" ] || continue  # Handle no matches
    echo "$file"
done

# ❌ BAD - Process substitution (not POSIX)
while read line; do
    echo "$line"
done < <(command)
```

### Safe Command Execution
```sh
# Check command exists
if command -v mycommand >/dev/null 2>&1; then
    mycommand
fi

# Portable which
command -v command_name >/dev/null 2>&1

# Capture output safely
output=$(command 2>&1) || {
    echo "Command failed: $output"
    exit 1
}
```

## Common Pitfalls

### 1. echo vs printf
```sh
# ❌ echo is not fully portable (flags vary)
echo -n "text"
echo -e "text\n"

# ✅ printf is POSIX and portable
printf "%s" "text"
printf "%s\n" "text"
```

### 2. Pipeline failures
```sh
# ❌ Only checks last command
command1 | command2 | command3

# ✅ Check each command
command1 || exit 1
command1_output=$(command1) || exit 1
echo "$command1_output" | command2 || exit 1
```

### 3. Temporary files
```sh
# ❌ Insecure
tmpfile="/tmp/myfile.$$"

# ✅ Use mktemp (POSIX)
tmpfile=$(mktemp) || exit 1
trap 'rm -f "$tmpfile"' EXIT INT TERM
```

## References
- POSIX.1-2017 Standard
- dash man page
- checkbashisms
- ShellCheck POSIX mode
