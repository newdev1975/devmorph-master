# ADR 001: POSIX Compliance as Foundation

## Status
Accepted

## Context
Building truly cross-platform framework requires maximum compatibility.

Options considered:
1. **Bash-centric** - Use Bash features, require Bash 4+
2. **POSIX-compliant** - Use POSIX sh as baseline
3. **Shell-specific** - Different implementations per shell

## Decision
**Implement POSIX sh compliance as baseline** with feature detection.

### POSIX sh Baseline
- All core functionality works in plain POSIX sh
- No bashisms in core code
- Test with dash (strictest POSIX shell)

### Feature Detection (not version detection)
- Detect capabilities at runtime
- Use advanced features when available
- Graceful fallback to POSIX

### Shell-Specific Adapters
- BashAdapter - Bash optimizations (associative arrays, etc.)
- ZshAdapter - Zsh-specific features
- PowerShellAdapter - Windows native support

## Consequences

### Positive
- **Maximum Compatibility**: Works on ALL Unix-like systems
  - Linux (dash, bash, zsh, ksh, ash)
  - macOS (sh, bash, zsh)
  - BSD (sh, bash, ksh)
  - Solaris, AIX, HP-UX
- **Minimal Dependencies**: Only POSIX utilities required
- **Predictable Behavior**: POSIX spec is well-defined
- **Future-Proof**: POSIX is stable standard
- **Testable**: Can test with strictest shell (dash)

### Negative
- **No Bashisms**: Can't use arrays, [[ ]], etc. in core
- **More Verbose**: POSIX constructs sometimes longer
- **Performance**: Slight overhead vs. bash-specific code

## POSIX Requirements

### Forbidden (Non-POSIX):
- `[[  ]]` - Use `[  ]` instead
- `$((  ))` for strings - Use `expr` or `awk`
- Arrays - Use positional parameters or external storage
- Associative arrays - Use external key-value storage
- `local` keyword - Function variables require careful scoping
- Bash process substitution `<()` - Use temp files
- `${var^^}`, `${var,,}` - Use `tr` instead
- `+=` for strings - Use explicit concatenation
- `source` - Use `.` (dot) instead

### Required (POSIX-compliant):
- `[  ]` - Test command
- `case` - Pattern matching
- `expr` - Arithmetic and string operations
- `awk`, `sed`, `grep` - Text processing
- `cut`, `tr`, `sort` - Utilities
- `.` - Source files (not `source`)
- Pipes and redirections
- Functions (POSIX syntax)
- `${var}` parameter expansion (basic forms)

## Testing Strategy
1. **Primary**: Test with `/bin/dash` (strictest POSIX)
2. **Secondary**: Test with `bash`, `zsh`, `ksh`
3. **Windows**: Test with PowerShell adapter
4. **CI/CD**: Run tests on all platforms

## Implementation Rules

### Rule 1: Core = Pure POSIX
```sh
# ❌ BAD (Bash-specific)
if [[ -n "$var" ]]; then
    array+=("item")
fi

# ✅ GOOD (POSIX-compliant)
if [ -n "$var" ]; then
    set -- "$@" "item"
fi
```

### Rule 2: Feature Detection
```sh
# ❌ BAD (Version detection)
if [ "$BASH_VERSION" \> "4.0" ]; then
    use_associative_arrays
fi

# ✅ GOOD (Feature detection)
if command -v declare >/dev/null 2>&1; then
    if declare -A test_array 2>/dev/null; then
        use_associative_arrays
    fi
fi
```

### Rule 3: Graceful Degradation
```sh
# Try advanced feature, fall back to POSIX
if supports_arrays; then
    # Use bash arrays for performance
    use_fast_array_implementation
else
    # Fall back to POSIX positional parameters
    use_posix_implementation
fi
```

## Validation
- Run `checkbashisms` on all shell scripts
- Test suite must pass on dash
- CI/CD tests on multiple platforms

## References
- POSIX.1-2017 (IEEE Std 1003.1-2017)
- dash as reference implementation
- checkbashisms tool for validation
