# DevMorph AI Studio - Workspace Manager Troubleshooting Guide

## Table of Contents
1. [Common Issues](#common-issues)
2. [Docker Problems](#docker-problems)
3. [Workspace Management](#workspace-management)
4. [Mode Switching](#mode-switching)
5. [Template Issues](#template-issues)
6. [Performance Problems](#performance-problems)
7. [Security Issues](#security-issues)
8. [Network Problems](#network-problems)
9. [File System Issues](#file-system-issues)
10. [System Compatibility](#system-compatibility)

## Common Issues

### Command Not Found
**Problem**: `devmorph: command not found` or similar error
**Cause**: The devmorph script is not in your PATH or not executable
**Solution**:
```bash
# Make sure the script is executable
chmod +x /path/to/devmorph

# Add to PATH or use full path
export PATH="$PATH:/path/to/devmorph-directory"
# OR
/path/to/devmorph/workspace-manager/devmorph workspace list
```

### Permission Denied
**Problem**: `Permission denied` when running commands
**Cause**: Insufficient permissions to access Docker or workspace directories
**Solution**:
```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Then logout and login again

# Fix workspace directory permissions
chmod -R 755 /path/to/workspace-directory
chown -R $USER:$USER /path/to/workspace-directory
```

### Invalid Workspace Name
**Problem**: `Error: Invalid workspace name` or similar validation error
**Cause**: Workspace name contains invalid characters or format
**Solution**:
```bash
# Valid workspace names:
# - Alphanumeric characters (a-z, A-Z, 0-9)
# - Hyphens (-) and underscores (_)
# - 1-64 characters long
# - Cannot be reserved names (., .., /)

# Examples of valid names:
devmorph workspace create --name my-project --template default
devmorph workspace create --name project_2025 --template default
devmorph workspace create --name test-project-alpha --template default

# Examples of INVALID names:
devmorph workspace create --name "my project" --template default  # Contains space
devmorph workspace create --name ../../../etc/passwd --template default  # Path traversal
devmorph workspace create --name "" --template default  # Empty name
```

## Docker Problems

### Docker Not Installed
**Problem**: `Error: Docker is not installed or not in PATH`
**Cause**: Docker is not installed or not accessible
**Solution**:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER

# macOS
# Download Docker Desktop from https://www.docker.com/products/docker-desktop

# CentOS/RHEL/Fedora
sudo yum install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker-compose --version
```

### Docker Daemon Not Running
**Problem**: `Error: Docker daemon is not running`
**Cause**: Docker service is not started
**Solution**:
```bash
# Linux
sudo systemctl start docker
sudo systemctl enable docker

# Check status
sudo systemctl status docker

# Verify Docker is working
docker info
```

### Docker Compose Not Available
**Problem**: `Error: Docker Compose is not installed or not in PATH`
**Cause**: Docker Compose is not installed or Docker Compose V2 is not available
**Solution**:
```bash
# Install Docker Compose (standalone)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Or use Docker Compose V2 (included with newer Docker versions)
# Check if available:
docker compose version

# If not available, update Docker:
# Ubuntu/Debian
sudo apt-get update
sudo apt-get upgrade docker.io

# CentOS/RHEL
sudo yum update docker
```

### Container Fails to Start
**Problem**: `Error: Failed to start Docker Compose services`
**Cause**: Various issues with Docker Compose configuration or container images
**Solution**:
```bash
# Check Docker Compose file syntax
docker-compose config  # In workspace directory

# Check container logs
docker-compose logs

# Check individual service logs
docker-compose logs service-name

# Validate Docker Compose file
docker-compose config --services

# Try rebuilding images
docker-compose build --no-cache
docker-compose up -d
```

### Port Already in Use
**Problem**: `Error: Port already in use`
**Cause**: Another service is using the required port
**Solution**:
```bash
# Check what's using the port
sudo netstat -tulpn | grep :3000
# OR
sudo lsof -i :3000

# Kill the process using the port
sudo kill -9 PID

# Or change the port mapping in docker-compose.yml
# Edit the workspace's docker-compose.yml file and change:
# ports:
#   - "3001:3000"  # Change host port to 3001
```

### Insufficient Resources
**Problem**: Containers fail to start or work slowly
**Cause**: System doesn't have enough memory or CPU resources
**Solution**:
```bash
# Check system resources
free -h
df -h

# Check Docker resource usage
docker stats

# Increase Docker resource limits (Docker Desktop):
# Preferences -> Resources -> Adjust memory/CPU allocations

# Optimize workspace resource usage:
# Edit docker-compose.yml and adjust resource limits:
# deploy:
#   resources:
#     limits:
#       memory: 1G
#       cpus: '0.5'
```

## Workspace Management

### Workspace Already Exists
**Problem**: `Error: Workspace 'name' already exists`
**Cause**: Trying to create a workspace with a name that's already in use
**Solution**:
```bash
# List existing workspaces
devmorph workspace list

# Choose a different name
devmorph workspace create --name my-project-alt --template default

# Or destroy the existing workspace first
devmorph workspace destroy my-project
devmorph workspace create --name my-project --template default
```

### Workspace Doesn't Exist
**Problem**: `Error: Workspace 'name' does not exist`
**Cause**: Trying to operate on a workspace that hasn't been created
**Solution**:
```bash
# Check if workspace exists
devmorph workspace list

# Create the workspace first
devmorph workspace create --name my-project --template default

# Then operate on it
devmorph workspace start my-project
```

### Workspace Won't Start
**Problem**: `Error: Failed to start workspace`
**Cause**: Various configuration or dependency issues
**Solution**:
```bash
# Check workspace status
devmorph workspace list

# Check logs in workspace directory
cat my-project/.devmorph/logs/*

# Check Docker container status
cd my-project
docker-compose ps

# Check container logs
docker-compose logs

# Try restarting
devmorph workspace stop my-project
devmorph workspace start my-project
```

### Workspace Won't Stop
**Problem**: `Error: Failed to stop workspace`
**Cause**: Docker Compose issues or containers in problematic state
**Solution**:
```bash
# Force stop containers
cd my-project
docker-compose down --remove-orphans

# If that fails, kill containers directly
docker ps | grep my-project
docker kill CONTAINER_ID

# Remove stopped containers
docker rm CONTAINER_ID
```

### Workspace Destruction Fails
**Problem**: `Error: Failed to destroy workspace`
**Cause**: Permission issues or files in use
**Solution**:
```bash
# Try with sudo if permission issues
sudo devmorph workspace destroy my-project

# Stop workspace first if it's running
devmorph workspace stop my-project
devmorph workspace destroy my-project

# Manually remove if necessary
cd ..
rm -rf my-project
```

## Mode Switching

### Invalid Mode Error
**Problem**: `Error: Invalid mode 'name'`
**Cause**: Specifying a mode that doesn't exist
**Solution**:
```bash
# Check available modes
devmorph workspace mode show my-project

# Valid modes are:
# dev, prod, staging, test, design, mix

# Correct usage:
devmorph workspace mode set my-project --mode prod
```

### Mode Change Doesn't Take Effect
**Problem**: Workspace still uses old mode after switching
**Cause**: Workspace needs to be restarted for mode changes to take effect
**Solution**:
```bash
# Stop workspace
devmorph workspace stop my-project

# Change mode
devmorph workspace mode set my-project --mode prod

# Start workspace
devmorph workspace start my-project
```

### Mode-Specific Service Issues
**Problem**: Certain services don't work in specific modes
**Cause**: Mode-specific configurations or resource constraints
**Solution**:
```bash
# Check mode-specific docker-compose files
ls -la workspace-manager/modes/*/docker-compose.yml

# Check workspace docker-compose.yml after mode switch
cat my-project/docker-compose.yml

# Compare with template
diff templates/default/docker-compose.yml my-project/docker-compose.yml
```

## Template Issues

### Template Not Found
**Problem**: `Error: Template 'name' does not exist`
**Cause**: Specified template doesn't exist in templates directory
**Solution**:
```bash
# Check available templates
ls -la templates/

# Use existing template
devmorph workspace create --name my-project --template default

# Or create the template
mkdir -p templates/my-template
# Add template files...
```

### Template Validation Failed
**Problem**: `Error: Invalid template name`
**Cause**: Template name contains invalid characters
**Solution**:
```bash
# Valid template names:
# - Alphanumeric characters (a-z, A-Z, 0-9)
# - Hyphens (-) and underscores (_)
# - 1-64 characters long

# Examples of valid names:
devmorph workspace create --name my-project --template default
devmorph workspace create --name my-project --template react-app
devmorph workspace create --name my-project --template node-express

# Examples of INVALID names:
devmorph workspace create --name my-project --template "my template"  # Contains space
devmorph workspace create --name my-project --template ../../etc  # Path traversal
```

### Template Files Missing
**Problem**: Workspace created but missing files
**Cause**: Template directory incomplete or corrupted
**Solution**:
```bash
# Check template contents
ls -la templates/default/

# Should contain at minimum:
# - docker-compose.yml
# - Source files or directories

# Recreate template if necessary
cp -r templates/default templates/my-fixed-template
# Fix issues in my-fixed-template
devmorph workspace create --name my-project --template my-fixed-template
```

## Performance Problems

### Slow Workspace Startup
**Problem**: Workspaces taking too long to start
**Cause**: Large images, slow network, or insufficient resources
**Solution**:
```bash
# Check Docker image sizes
docker images

# Pull images in advance
docker-compose pull

# Check network speed
ping registry.hub.docker.com

# Use cached builds
docker-compose build --no-cache

# Monitor resource usage
docker stats
```

### High Memory Usage
**Problem**: System memory exhausted when running workspaces
**Cause**: Too many workspaces running or insufficient memory limits
**Solution**:
```bash
# Check memory usage per container
docker stats

# Set memory limits in docker-compose.yml:
# deploy:
#   resources:
#     limits:
#       memory: 512M

# Stop unused workspaces
devmorph workspace list
devmorph workspace stop unused-workspace

# Prune unused Docker resources
docker system prune -a
```

### Slow File Operations
**Problem**: Slow file copying or template processing
**Cause**: Large files, slow disk, or network filesystem
**Solution**:
```bash
# Check disk performance
hdparm -Tt /dev/sda

# Move workspaces to local SSD
mv /network/workspace /local/ssd/workspace

# Optimize file operations
# Use rsync instead of cp for large directories
rsync -av source/ destination/
```

## Security Issues

### Path Traversal Detected
**Problem**: `Error: Path traversal detected`
**Cause**: Attempting to access files outside intended directories
**Solution**:
```bash
# Use only valid workspace names
# Valid: my-project, test_workspace, project-2025
# Invalid: ../../etc, ../../../var/log, .

# Create workspaces in current directory only
cd /safe/directory
devmorph workspace create --name my-safe-project --template default
```

### Permission Errors
**Problem**: `Permission denied` when accessing files
**Cause**: Incorrect file permissions or ownership
**Solution**:
```bash
# Fix file ownership
sudo chown -R $USER:$USER my-project

# Fix file permissions
chmod -R 755 my-project
find my-project -type f -exec chmod 644 {} \;

# Check umask setting
umask 022
```

### Docker Security Warnings
**Problem**: Security warnings in Docker logs
**Cause**: Containers running with insecure configurations
**Solution**:
```bash
# Run containers as non-root
# In docker-compose.yml:
# user: "1000:1000"

# Drop unnecessary capabilities
# cap_drop:
#   - ALL

# Enable security options
# security_opt:
#   - "no-new-privileges:true"

# Use read-only root filesystem when possible
# read_only: true
# tmpfs:
#   - /tmp
#   - /var/tmp
```

## Network Problems

### Cannot Connect to Services
**Problem**: Unable to access workspace services in browser
**Cause**: Wrong port, service not running, or network issues
**Solution**:
```bash
# Check if service is running
devmorph workspace list
cd my-project
docker-compose ps

# Check port mappings
docker-compose port app 3000

# Test connectivity locally
curl -v http://localhost:3000

# Check service logs
docker-compose logs app
```

### DNS Resolution Issues
**Problem**: Services can't resolve domain names
**Cause**: DNS configuration problems in containers
**Solution**:
```bash
# Test DNS resolution in container
docker-compose exec app nslookup google.com

# Check Docker DNS settings
# In docker-compose.yml:
# dns:
#   - 8.8.8.8
#   - 8.8.4.4

# Use host networking if needed
# network_mode: host
```

### Network Conflicts
**Problem**: Port conflicts or IP address conflicts
**Cause**: Multiple services trying to use same ports or IPs
**Solution**:
```bash
# Change host port mapping
# In docker-compose.yml:
# ports:
#   - "3001:3000"  # Change 3000 to 3001

# Use different networks
# In docker-compose.yml:
# networks:
#   app-network:
#     driver: bridge

# Check for conflicting processes
sudo netstat -tulpn | grep :3000
```

## File System Issues

### Disk Space Exhausted
**Problem**: `No space left on device`
**Cause**: Insufficient disk space for Docker images or workspace files
**Solution**:
```bash
# Check disk usage
df -h

# Check Docker disk usage
docker system df

# Clean up unused Docker resources
docker system prune -a

# Remove unused volumes
docker volume prune

# Clean up specific workspaces
devmorph workspace destroy old-project
```

### File Corruption
**Problem**: Workspace files corrupted or inconsistent
**Cause**: System crashes, power loss, or disk errors
**Solution**:
```bash
# Check file integrity
cd my-project
find . -type f -exec md5sum {} \; > checksums.md5

# Rebuild workspace from template
devmorph workspace destroy corrupted-project
devmorph workspace create --name corrupted-project --template default

# Check disk for errors (Linux)
sudo fsck /dev/sda1
```

### Symbolic Link Issues
**Problem**: Problems with symbolic links in workspaces
**Cause**: Broken or circular symbolic links
**Solution**:
```bash
# Find broken symlinks
find . -type l -exec test ! -e {} \; -print

# Remove broken symlinks
find . -type l -exec test ! -e {} \; -delete

# Create proper symlinks
ln -sf target link-name
```

## System Compatibility

### Shell Compatibility Issues
**Problem**: Scripts fail on certain systems
**Cause**: Non-POSIX compliant shell features used
**Solution**:
```bash
# Use POSIX-compliant shell
#!/bin/sh  # Instead of #!/bin/bash

# Avoid bash-specific features:
# Use ${var:-default} instead of ${var?default}
# Use $(command) instead of `command`
# Use case instead of [[ ]]

# Test on multiple shells
dash script.sh
sh script.sh
bash script.sh
```

### OS-Specific Issues
**Problem**: Different behavior on Linux vs macOS vs Windows
**Cause**: OS-specific differences in file systems, paths, or commands
**Solution**:
```bash
# Use portable commands
# Use grep -E instead of egrep
# Use sed -i '' on macOS for in-place editing

# Handle path separators
# Use / instead of \ for paths
# Use $(pwd) instead of hardcoded paths

# Check OS before executing OS-specific code
case "$(uname -s)" in
    Linux*)   # Linux specific code ;;
    Darwin*)  # macOS specific code ;;
    *)        # Default/fallback code ;;
esac
```

### Docker Version Compatibility
**Problem**: Features don't work with older Docker versions
**Cause**: Using Docker Compose V2 features with V1 or vice versa
**Solution**:
```bash
# Check Docker versions
docker --version
docker-compose --version

# Use compatible syntax
# For Docker Compose V1:
# docker-compose up -d

# For Docker Compose V2:
# docker compose up -d

# Check feature availability
docker compose version >/dev/null 2>&1 && echo "V2 available" || echo "V1 or none"
```

## Advanced Troubleshooting

### Enabling Debug Mode
```bash
# Enable detailed logging
export DEVMORPH_LOG_LEVEL=debug
export DEVMORPH_DEBUG=1

# Run command with debug output
devmorph workspace create --name debug-test --template default

# Check debug logs
cat .devmorph/logs/debug.log
```

### Checking System Compatibility
```bash
# Run compatibility check
./workspace-manager/utils/compatibility.sh

# Check POSIX compliance
sh -c 'echo "Test"'  # Should work
grep --version       # Check available
sed --version        # Check available

# Check Docker compatibility
docker info
docker-compose version
```

### Collecting Diagnostic Information
```bash
# Gather system information
uname -a
docker --version
docker-compose --version
df -h
free -h

# Gather workspace information
devmorph workspace list
cd my-project
ls -la
docker-compose config
docker-compose ps
docker-compose logs

# Create diagnostic bundle
tar czf diagnostic-bundle.tar.gz \
  .devmorph/logs/ \
  .devmorph-state \
  docker-compose.yml
```

## Getting Help

### Community Resources
- GitHub Issues: https://github.com/devmorph/workspace-manager/issues
- Documentation: Built-in help and online guides
- Community Forums: Coming soon

### Professional Support
- Enterprise Support Plans: Contact sales@devmorph.com
- Professional Services: Available for custom implementations
- Training Programs: Hands-on workshops and certification

### Reporting Issues
When reporting issues, include:
1. Exact error message
2. Command that failed
3. System information (OS, Docker version)
4. Steps to reproduce
5. Diagnostic information bundle

---

*Last updated: July 03, 2025*