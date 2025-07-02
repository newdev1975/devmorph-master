# DevMorph AI Studio - Workspace Manager Security Guide

## Table of Contents
1. [Overview](#overview)
2. [Threat Model](#threat-model)
3. [Security Controls](#security-controls)
4. [Input Validation](#input-validation)
5. [Path Traversal Protection](#path-traversal-protection)
6. [Command Injection Prevention](#command-injection-prevention)
7. [File System Security](#file-system-security)
8. [Docker Security](#docker-security)
9. [Network Security](#network-security)
10. [Authentication and Authorization](#authentication-and-authorization)
11. [Auditing and Logging](#auditing-and-logging)
12. [Security Testing](#security-testing)

## Overview

This document outlines the security measures implemented in the DevMorph AI Studio Workspace Manager and provides guidance for maintaining and enhancing security.

The Workspace Manager follows security-by-design principles with multiple layers of protection against common vulnerabilities including:

- Path traversal attacks
- Command injection
- Input validation bypasses
- File system privilege escalation
- Docker container escapes
- Network-based attacks

## Threat Model

### Identified Threats

#### 1. Path Traversal Attacks
**Description**: Malicious users attempt to access files outside the intended workspace directory by manipulating file paths.

**Impact**: Unauthorized access to system files, configuration exposure, data leakage.

**Likelihood**: Medium

#### 2. Command Injection
**Description**: Attackers inject malicious commands through user inputs that are improperly handled in shell executions.

**Impact**: Arbitrary command execution, system compromise, data theft.

**Likelihood**: High

#### 3. Input Validation Bypass
**Description**: Users bypass input validation to create workspaces or templates with malicious names or content.

**Impact**: System instability, resource exhaustion, potential exploitation.

**Likelihood**: Medium

#### 4. File System Privilege Escalation
**Description**: Exploitation of file permissions to gain unauthorized access to system resources.

**Impact**: Unauthorized file access, modification of system files, privilege escalation.

**Likelihood**: Low

#### 5. Docker Container Escapes
**Description**: Exploitation of Docker vulnerabilities to escape container boundaries.

**Impact**: Host system compromise, unauthorized access to other workspaces.

**Likelihood**: Low

#### 6. Network-Based Attacks
**Description**: Attacks against exposed Docker services or communication channels.

**Impact**: Service disruption, data interception, unauthorized access.

**Likelihood**: Medium

## Security Controls

### Defense in Depth Strategy

The Workspace Manager implements multiple layers of security controls:

1. **Input Validation**: Strict validation of all user inputs at entry points
2. **Path Sanitization**: Comprehensive path traversal protection
3. **Command Escaping**: Proper escaping of shell commands
4. **File Permissions**: Secure file and directory permissions
5. **Docker Hardening**: Security-hardened container configurations
6. **Network Segmentation**: Isolated Docker networks
7. **Auditing**: Comprehensive logging and monitoring
8. **Regular Updates**: Automated security updates and patching

### Security Architecture Diagram

```
User Input → [Input Validation] → [Path Sanitization] → [Command Escaping] → Docker Operations
     ↓              ↓                    ↓                    ↓                  ↓
   Logger      Path Validator      Safe Command      File Permissions     Container Security
     ↓              ↓                    ↓                    ↓                  ↓
   Audit Trail   Exception Handler   Exception Handler   Access Controls   Network Policies
```

## Input Validation

### Validation Principles

1. **Whitelist Approach**: Only allow known good inputs
2. **Early Rejection**: Validate inputs as early as possible
3. **Context-Aware**: Apply appropriate validation for each context
4. **Fail Secure**: Reject invalid inputs securely

### Workspace Name Validation

```bash
validate_workspace_name() {
    local name="$1"
    
    # Check if name is provided
    if [ -z "$name" ]; then
        log_error "Workspace name cannot be empty"
        return 10  # Custom error code for invalid workspace name
    fi
    
    # Check for invalid characters
    if ! echo "$name" | grep -qE '^[a-zA-Z0-9_-]+$'; then
        log_error "Workspace name contains invalid characters"
        return 10
    fi
    
    # Check length limitations
    if [ ${#name} -gt 64 ]; then
        log_error "Workspace name too long (max 64 characters)"
        return 10
    fi
    
    # Check for reserved names
    case "$name" in
        "."|".."|"/")
            log_error "Workspace name is a reserved name"
            return 10
            ;;
    esac
    
    # Additional security checks for path traversal patterns
    if echo "$name" | grep -qE '(\.\.|\/\/|\\\\)'; then
        log_error "Workspace name contains dangerous traversal patterns"
        return 19  # Custom error code for path traversal
    fi
    
    return 0
}
```

### Template Name Validation

```bash
validate_template_name() {
    local template="$1"
    
    # Check if template name is provided
    if [ -z "$template" ]; then
        log_error "Template name cannot be empty"
        return 11  # Custom error code for invalid template name
    fi
    
    # Check for invalid characters
    if ! echo "$template" | grep -qE '^[a-zA-Z0-9_-]+$'; then
        log_error "Template name contains invalid characters"
        return 11
    fi
    
    # Check length limitations
    if [ ${#template} -gt 64 ]; then
        log_error "Template name too long (max 64 characters)"
        return 11
    fi
    
    # Check for reserved names
    case "$template" in
        "."|".."|"/")
            log_error "Template name is a reserved name"
            return 11
            ;;
    esac
    
    return 0
}
```

### Mode Validation

```bash
validate_mode() {
    local mode="$1"
    
    # Check if mode is provided
    if [ -z "$mode" ]; then
        log_error "Mode cannot be empty"
        return 12  # Custom error code for invalid mode
    fi
    
    # Check against allowed modes
    case "$mode" in
        "dev"|"prod"|"staging"|"test"|"design"|"mix")
            return 0
            ;;
        *)
            log_error "Invalid mode: $mode"
            return 12
            ;;
    esac
}
```

## Path Traversal Protection

### Path Validation Functions

```bash
validate_path() {
    local path="$1"
    
    # Check if path is provided
    if [ -z "$path" ]; then
        log_error "Path cannot be empty"
        return 19
    fi
    
    # Check for dangerous patterns that could lead to directory traversal
    case "$path" in
        */..|*../|*../*|/*|../*|*//*)
            log_error "Path contains dangerous traversal patterns"
            return 19
            ;;
    esac
    
    # Resolve the path and make sure it's under the current directory
    local abs_path
    local current_dir
    abs_path=$(get_absolute_path "$path" 2>/dev/null)
    current_dir=$(get_absolute_path "." 2>/dev/null)
    
    case "$abs_path" in
        "$current_dir"/*|"$current_dir")
            # Path is within current directory, which is safe
            return 0
            ;;
        *)
            # Path is outside current directory, which is dangerous
            log_error "Path resolves outside current directory"
            return 19
            ;;
    esac
}

validate_workspace_path() {
    local path="$1"
    
    # Additional validation specific to workspace paths
    case "$path" in
        */..|*../|*../*|/*|../*|*//*)
            log_error "Workspace path contains dangerous traversal patterns"
            return 19
            ;;
        */.devmorph/*|*/.devmorph-state)
            log_error "Workspace path attempts to access protected files"
            return 18
            ;;
    esac
    
    # Validate general path safety
    validate_path "$path"
    return $?
}
```

### Safe Path Resolution

```bash
get_absolute_path() {
    local path="$1"
    
    # Use canonical path resolution to prevent symbolic link tricks
    if [ -d "$path" ]; then
        (CDPATH= cd -- "$path" && pwd -P 2>/dev/null)
    elif [ -f "$path" ]; then
        (CDPATH= cd -- "$(dirname -- "$path")" && pwd -P 2>/dev/null)/$(basename -- "$path")
    else
        # For non-existent paths, resolve the directory part
        (CDPATH= cd -- "$(dirname -- "$path")" && pwd -P 2>/dev/null)/$(basename -- "$path")
    fi
}
```

### Secure File Operations

```bash
safe_copy() {
    local src="$1"
    local dst="$2"
    
    # Validate source and destination paths
    validate_path "$src"
    if [ $? -ne 0 ]; then
        return 19
    fi
    
    validate_path "$dst"
    if [ $? -ne 0 ]; then
        return 19
    fi
    
    # Use safer copy method to prevent path traversal
    if [ -d "$src" ]; then
        # Copy directory contents
        if ! (cd "$src" && tar cf - . 2>/dev/null) | (cd "$dst" && tar xf - 2>/dev/null); then
            log_error "Failed to copy directory from '$src' to '$dst'"
            return 1
        fi
    else
        # Copy file
        if ! cp "$src" "$dst" 2>/dev/null; then
            log_error "Failed to copy file from '$src' to '$dst'"
            return 1
        fi
    fi
    
    return 0
}
```

## Command Injection Prevention

### Safe Command Construction

```bash
# Dangerous - DO NOT USE
# eval "docker-compose -f $workspace_path/docker-compose.yml up -d"

# Safe - USE THIS APPROACH
docker_compose_up() {
    local workspace_path="$1"
    local compose_file="$workspace_path/docker-compose.yml"
    
    # Validate workspace path to prevent injection
    validate_workspace_path "$workspace_path"
    if [ $? -ne 0 ]; then
        return 19
    fi
    
    # Check if compose file exists
    if [ ! -f "$compose_file" ]; then
        log_error "Docker Compose file not found: $compose_file"
        return 1
    fi
    
    # Use proper quoting to prevent command injection
    if command -v docker-compose >/dev/null 2>&1; then
        docker-compose -f "$compose_file" up -d
    else
        docker compose -f "$compose_file" up -d
    fi
}
```

### Input Escaping

```bash
escape_for_shell() {
    local input="$1"
    
    # Escape special shell characters
    printf '%s\n' "$input" | sed 's/[$`"\\]/\\&/g'
}

escape_for_sed() {
    local input="$1"
    
    # Escape special sed characters
    printf '%s\n' "$input" | sed 's/[&/\]/\\&/g'
}
```

### Parameterized Command Execution

```bash
execute_with_validation() {
    local command="$1"
    local param1="$2"
    local param2="$3"
    
    # Validate all parameters
    validate_workspace_name "$param1"
    if [ $? -ne 0 ]; then
        return 10
    fi
    
    validate_template_name "$param2"
    if [ $? -ne 0 ]; then
        return 11
    fi
    
    # Execute command with properly quoted parameters
    "$command" "$param1" "$param2"
}
```

## File System Security

### Secure File Permissions

```bash
set_secure_permissions() {
    local path="$1"
    
    # Set restrictive permissions for configuration files
    if [ -f "$path" ]; then
        chmod 600 "$path" 2>/dev/null || log_warn "Failed to set permissions for $path"
    fi
    
    # Set restrictive permissions for directories
    if [ -d "$path" ]; then
        chmod 700 "$path" 2>/dev/null || log_warn "Failed to set permissions for $path"
    fi
}

create_secure_file() {
    local file_path="$1"
    
    # Create file with restrictive permissions
    touch "$file_path" 2>/dev/null
    set_secure_permissions "$file_path"
}
```

### Protected File Access

```bash
# Prevent direct access to sensitive files
protect_sensitive_files() {
    local workspace_path="$1"
    local protected_files=".devmorph-state .devmorph/config.json"
    
    for file in $protected_files; do
        local full_path="$workspace_path/$file"
        if [ -f "$full_path" ]; then
            set_secure_permissions "$full_path"
        fi
    done
}
```

### Temporary File Security

```bash
create_secure_temp_file() {
    local prefix="$1"
    
    # Use mktemp if available for secure temporary files
    if command -v mktemp >/dev/null 2>&1; then
        mktemp --tmpdir "${prefix}_XXXXXX" 2>/dev/null
    else
        # Fallback with proper permissions
        local temp_dir="${TMPDIR:-/tmp}"
        local temp_file="$temp_dir/${prefix}_$$"
        touch "$temp_file" 2>/dev/null
        chmod 600 "$temp_file" 2>/dev/null
        echo "$temp_file"
    fi
}
```

## Docker Security

### Container Hardening

```yaml
# docker-compose.yml security best practices
version: '3.8'

services:
  app:
    # Run as non-root user
    user: "1000:1000"
    
    # Security options
    security_opt:
      - "no-new-privileges:true"
    
    # Capabilities
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if needed
    
    # Read-only root filesystem (when possible)
    read_only: true
    tmpfs:
      - /tmp
      - /var/tmp
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    
    # Restart policies
    restart: unless-stopped
    
    # Health checks
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Docker Daemon Security

```bash
check_docker_security() {
    # Check if Docker daemon is running with proper security options
    if ! docker info --format '{{.SecurityOptions}}' | grep -q 'name=userns'; then
        log_warn "Docker user namespace remapping not enabled"
    fi
    
    # Check for proper TLS configuration
    if [ -n "$DOCKER_TLS_VERIFY" ] && [ "$DOCKER_TLS_VERIFY" != "1" ]; then
        log_warn "Docker TLS verification not enabled"
    fi
}
```

### Network Isolation

```yaml
# docker-compose.yml network isolation
version: '3.8'

networks:
  app-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
    driver_opts:
      com.docker.network.bridge.enable_ip_masquerade: "true"
      com.docker.network.bridge.enable_icc: "false"  # Disable inter-container communication
      com.docker.network.bridge.host_binding_ipv4: "127.0.0.1"  # Bind to localhost only

services:
  app:
    networks:
      - app-network
```

## Network Security

### Port Binding Security

```bash
validate_port_binding() {
    local port="$1"
    local host_binding="$2"
    
    # Only allow binding to localhost for development
    if [ "$host_binding" != "127.0.0.1" ] && [ "$host_binding" != "localhost" ]; then
        log_warn "Port binding to external address detected: $host_binding"
        # In production, reject external bindings
        if [ "$DEVMORPH_ENV" = "prod" ]; then
            log_error "External port binding not allowed in production"
            return 1
        fi
    fi
    
    # Validate port range
    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        log_error "Invalid port number: $port"
        return 1
    fi
    
    return 0
}
```

### Firewall Integration

```bash
setup_firewall_rules() {
    local workspace_name="$1"
    
    # Use iptables or firewall-cmd to restrict network access
    # This is an example - actual implementation depends on system
    if command -v iptables >/dev/null 2>&1; then
        # Restrict outbound connections for specific containers
        # This would typically be handled by Docker networks
        log_info "Firewall rules would be configured here"
    fi
}
```

## Authentication and Authorization

### User Context Validation

```bash
validate_user_context() {
    # Check if running as appropriate user
    local current_uid=$(id -u)
    local current_gid=$(id -g)
    
    # Prevent running as root in production
    if [ "$current_uid" -eq 0 ] && [ "$DEVMORPH_ENV" = "prod" ]; then
        log_error "Running as root not allowed in production environment"
        return 1
    fi
    
    # Check group membership for Docker access
    if ! groups | grep -q docker; then
        log_warn "User not in docker group, Docker access may be restricted"
    fi
    
    return 0
}
```

### Access Control Lists

```bash
check_workspace_access() {
    local workspace_name="$1"
    local user_id="$2"
    
    # Check if user has access to workspace
    # This would typically be implemented with file permissions
    local workspace_path="./$workspace_name"
    
    if [ ! -r "$workspace_path" ] || [ ! -w "$workspace_path" ]; then
        log_error "Insufficient permissions for workspace: $workspace_name"
        return 18  # Permission denied
    fi
    
    return 0
}
```

## Auditing and Logging

### Security Event Logging

```bash
log_security_event() {
    local event_type="$1"
    local details="$2"
    local severity="$3"
    
    # Log security events to dedicated security log
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local log_entry="$timestamp [$severity] SECURITY_EVENT: $event_type - $details"
    
    # Write to security log file
    echo "$log_entry" >> "${DEVMORPH_SECURITY_LOG:-.devmorph/security.log}"
    
    # Also log to system log if available
    if command -v logger >/dev/null 2>&1; then
        logger -t "devmorph-security" "$log_entry"
    fi
}
```

### Audit Trail Implementation

```bash
audit_workspace_operation() {
    local operation="$1"
    local workspace_name="$2"
    local user="$3"
    local ip_address="$4"
    
    # Create audit record
    local audit_record
    audit_record=$(cat << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "operation": "$operation",
  "workspace": "$workspace_name",
  "user": "$user",
  "ip_address": "$ip_address",
  "success": true
}
EOF
)
    
    # Append to audit log
    echo "$audit_record" >> "${DEVMORPH_AUDIT_LOG:-.devmorph/audit.log}"
}
```

## Security Testing

### Automated Security Scanning

```bash
run_security_scan() {
    local workspace_path="$1"
    
    # Static analysis of shell scripts
    if command -v shellcheck >/dev/null 2>&1; then
        log_info "Running shellcheck security scan"
        shellcheck --severity=warning "$workspace_path"/*.sh
    fi
    
    # Docker image scanning
    if command -v docker >/dev/null 2>&1 && command -v dockle >/dev/null 2>&1; then
        log_info "Running Dockle security scan"
        dockle "$workspace_path"
    fi
    
    # Configuration file validation
    validate_config_files "$workspace_path"
}
```

### Penetration Testing Guidelines

#### Path Traversal Tests
```bash
# Test various path traversal attempts
test_path_traversal() {
    local test_cases="
    ../../../etc/passwd
    ../../../../etc/shadow
    ..//..//..//etc/passwd
    %2e%2e/%2e%2e/%2e%2e/etc/passwd
    ....//....//....//etc/passwd
    "
    
    for test_case in $test_cases; do
        if validate_workspace_name "$test_case"; then
            log_error "FAILED: Path traversal test passed unexpectedly: $test_case"
        else
            log_info "PASSED: Path traversal correctly rejected: $test_case"
        fi
    done
}
```

#### Command Injection Tests
```bash
# Test command injection attempts
test_command_injection() {
    local test_cases="
    '; rm -rf /'
    \"&& cat /etc/passwd\"
    '| ls -la'
    \`whoami\`
    \$(id)
    "
    
    for test_case in $test_cases; do
        # Test should fail validation
        if validate_workspace_name "$test_case"; then
            log_error "FAILED: Command injection test passed unexpectedly: $test_case"
        else
            log_info "PASSED: Command injection correctly rejected: $test_case"
        fi
    done
}
```

### Regular Security Assessments

```bash
schedule_security_assessment() {
    # Schedule regular security assessments
    local cron_job="0 2 * * 0 $SCRIPT_DIR/utils/security-scan.sh"
    
    # Add to crontab if not already present
    if ! crontab -l 2>/dev/null | grep -q "security-scan.sh"; then
        (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
        log_info "Scheduled weekly security assessment"
    fi
}
```

### Vulnerability Management

```bash
check_for_vulnerabilities() {
    # Check for known vulnerabilities in dependencies
    if command -v docker >/dev/null 2>&1; then
        # Scan Docker images for vulnerabilities
        log_info "Scanning Docker images for vulnerabilities"
        # This would use tools like Clair, Trivy, or similar
    fi
    
    # Check for outdated base images
    find . -name "Dockerfile" -exec grep -l "FROM " {} \; | while read dockerfile; do
        log_info "Checking base image in: $dockerfile"
        # Implementation for checking base image updates
    done
}
```

## Incident Response

### Security Incident Handling

```bash
handle_security_incident() {
    local incident_type="$1"
    local details="$2"
    
    # Log the incident
    log_security_event "$incident_type" "$details" "HIGH"
    
    # Notify administrators
    notify_administrators "$incident_type" "$details"
    
    # Take appropriate action based on incident type
    case "$incident_type" in
        "path_traversal_attempt")
            log_error "Path traversal attempt detected. Details: $details"
            # Block further attempts from this source
            ;;
        "command_injection_attempt")
            log_error "Command injection attempt detected. Details: $details"
            # Terminate affected processes
            ;;
        "unauthorized_access")
            log_error "Unauthorized access attempt detected. Details: $details"
            # Revoke access and change credentials
            ;;
    esac
    
    # Generate incident report
    generate_incident_report "$incident_type" "$details"
}
```

### Recovery Procedures

```bash
recover_from_security_breach() {
    local breach_type="$1"
    
    case "$breach_type" in
        "workspace_compromise")
            log_info "Initiating workspace recovery procedure"
            # Steps to recover from compromised workspace
            # 1. Isolate affected workspace
            # 2. Backup current state
            # 3. Recreate workspace from clean template
            # 4. Restore data from backups
            # 5. Validate integrity
            ;;
        "credential_compromise")
            log_info "Initiating credential recovery procedure"
            # Steps to recover from credential compromise
            # 1. Rotate all affected credentials
            # 2. Invalidate existing sessions
            # 3. Force password reset
            # 4. Audit access logs
            ;;
    esac
}
```

---

*Last updated: July 03, 2025*