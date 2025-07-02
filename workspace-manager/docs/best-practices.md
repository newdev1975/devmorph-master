# DevMorph AI Studio - Workspace Manager Best Practices Guide

## Table of Contents
1. [Workspace Naming](#workspace-naming)
2. [Template Design](#template-design)
3. [Mode Selection](#mode-selection)
4. [Resource Management](#resource-management)
5. [Security Practices](#security-practices)
6. [Workflow Optimization](#workflow-optimization)
7. [Collaboration](#collaboration)
8. [Maintenance](#maintenance)
9. [Performance Tuning](#performance-tuning)
10. [Enterprise Usage](#enterprise-usage)

## Workspace Naming

### Descriptive Naming Convention
Use clear, descriptive names that convey the purpose and context of each workspace:

```bash
# Good naming practices:
devmorph workspace create --name frontend-refactor-q4-2025 --template react
devmorph workspace create --name backend-api-v2-migration --template node-express
devmorph workspace create --name mobile-app-ios-feature --template react-native
devmorph workspace create --name data-analysis-q3-report --template python-data-science
devmorph workspace create --name marketing-campaign-assets --template design

# Avoid generic or unclear names:
devmorph workspace create --name project1 --template default  # ❌
devmorph workspace create --name temp --template default     # ❌
devmorph workspace create --name test-workspace --template default  # ❌
```

### Naming Structure Recommendations
Establish a consistent naming structure for your team or organization:

```bash
# Component-Feature-Version
frontend-dashboard-v1
backend-authentication-v2
mobile-navigation-redesign

# Project-Component-Task
ecommerce-cart-checkout
blog-comments-moderation
analytics-user-tracking

# Team-Month-Year-Purpose
engineering-oct-2025-refactor
design-nov-2025-branding
marketing-dec-2025-campaign
```

### Character Set Guidelines
Stick to safe characters to ensure compatibility across systems:

```bash
# Recommended characters:
# - Lowercase letters (a-z)
# - Numbers (0-9)
# - Hyphens (-)
# - Underscores (_)

# Valid examples:
my-awesome-project
feature_2025_update
q3_marketing_campaign
react_frontend_app

# Avoid these characters:
# - Spaces
# - Special characters (!@#$%^&*()+=[]{}|;:',<>/?~`)
# - Unicode characters
# - Reserved names (., .., /)
```

### Length Considerations
Keep names concise but descriptive:

```bash
# Recommended length: 1-32 characters
# Maximum length: 64 characters

# Good length:
devmorph workspace create --name api-gateway-refactor --template node
devmorph workspace create --name ui-component-library --template react

# Too long:
devmorph workspace create --name extremely-long-workspace-name-that-describes-every-single-detail-of-the-project --template default
```

## Template Design

### Template Structure Best Practices
Organize templates for clarity and reuse:

```
/templates/
├── frontend/                    # Frontend development templates
│   ├── react/                  # React applications
│   │   ├── basic/              # Basic React app
│   │   ├── with-redux/         # React with Redux state management
│   │   └── with-typescript/    # React with TypeScript
│   ├── vue/                    # Vue.js applications
│   └── angular/                # Angular applications
├── backend/                     # Backend service templates
│   ├── node-express/            # Node.js with Express
│   ├── python-flask/           # Python with Flask
│   └── java-spring/            # Java with Spring Boot
├── fullstack/                  # Full-stack application templates
│   ├── mern/                   # MongoDB, Express, React, Node
│   └── lamp/                   # Linux, Apache, MySQL, PHP
├── data-science/               # Data science and analytics
│   ├── python-jupyter/         # Python with Jupyter notebooks
│   └── r-shiny/                # R with Shiny applications
└── default/                    # Generic starter template
```

### Docker Compose Optimization
Configure Docker Compose files for optimal performance and security:

```yaml
# docker-compose.yml - Production-ready configuration
version: '3.8'

services:
  app:
    # Use specific version tags instead of 'latest'
    image: node:18-alpine
    
    # Run as non-root user for security
    user: "1000:1000"
    
    # Set resource limits
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
        reservations:
          memory: 512M
          cpus: '0.25'
    
    # Security hardening
    security_opt:
      - "no-new-privileges:true"
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if needed
    
    # Health checks
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    # Restart policies
    restart: unless-stopped
    
    # Environment variables
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info
    
    # Volume mounts for persistence
    volumes:
      - app_data:/app/data
      - ./logs:/app/logs:rw
    
    # Port mappings
    ports:
      - "127.0.0.1:3000:3000"  # Bind to localhost only
    
    # Network configuration
    networks:
      - app-network

  # Database service
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: app_db
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    secrets:
      - db_password
    networks:
      - app-network

# Named volumes for data persistence
volumes:
  app_data:
  db_data:

# Networks for service isolation
networks:
  app-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

# Secrets for sensitive data
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Configuration Management
Use environment files and configuration patterns for flexibility:

```bash
# .env.example - Template for environment variables
NODE_ENV=development
DATABASE_URL=postgresql://user:password@localhost:5432/database
REDIS_URL=redis://localhost:6379
API_PORT=3000
LOG_LEVEL=info
```

```yaml
# docker-compose.yml - Environment variable usage
version: '3.8'

services:
  app:
    build: .
    ports:
      - "${API_PORT:-3000}:${API_PORT:-3000}"
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - LOG_LEVEL=${LOG_LEVEL:-info}
    env_file:
      - .env
```

### Template Documentation
Include comprehensive documentation in templates:

```markdown
# React Application Template

## Overview
This template provides a modern React application with:
- Create React App foundation
- ESLint and Prettier configuration
- Jest testing setup
- Responsive design with Tailwind CSS
- Routing with React Router
- State management with Context API

## Quick Start
1. Create workspace: `devmorph workspace create --name my-react-app --template frontend/react/basic`
2. Start workspace: `devmorph workspace start my-react-app`
3. Access application: http://localhost:3000

## Features
- Hot reloading development server
- Production build optimization
- Code splitting and lazy loading
- TypeScript support (optional)
- CSS modules or Tailwind CSS
- Testing with Jest and React Testing Library

## Configuration
### Environment Variables
- `REACT_APP_API_URL`: Backend API endpoint
- `REACT_APP_ENV`: Environment (development, staging, production)
- `GENERATE_SOURCEMAP`: Generate source maps (true/false)

### Customization
- Modify `src/App.js` for application logic
- Update `src/components/` for UI components
- Configure `tailwind.config.js` for design tokens
- Adjust `jest.config.js` for testing setup

## Deployment
### Development
```bash
npm start
```

### Production
```bash
npm run build
```

## Troubleshooting
See [troubleshooting documentation](../../docs/troubleshooting.md) for common issues.
```

## Mode Selection

### When to Use Each Mode

#### Development Mode (dev)
```bash
# Use for active development and debugging
devmorph workspace create --name feature-branch --template default --mode dev

# Characteristics:
# - Hot reloading enabled
# - Debug ports exposed
# - Verbose logging
# - Volume mounts for live code updates
# - Resource limits disabled for flexibility
```

#### Production Mode (prod)
```bash
# Use for production deployments and demos
devmorph workspace create --name prod-deployment --template default --mode prod

# Characteristics:
# - Optimized for performance
# - Security hardened
# - Minimal logging
# - Resource limits enforced
# - Non-root user execution
```

#### Staging Mode (staging)
```bash
# Use for preview deployments and final testing
devmorph workspace create --name staging-release --template default --mode staging

# Characteristics:
# - Similar to production but with more visibility
# - Moderate logging
# - Staging-specific configurations
# - Resource limits similar to production
```

#### Test Mode (test)
```bash
# Use for automated testing and CI/CD pipelines
devmorph workspace create --name ci-test-suite --template default --mode test

# Characteristics:
# - Ephemeral data (clean state for each run)
# - Test-specific configurations
# - Single-run execution
# - Resource constraints for isolation
```

#### Design Mode (design)
```bash
# Use for creative work and asset management
devmorph workspace create --name design-assets --template default --mode design

# Characteristics:
# - Design tools via web interfaces
# - Asset storage with MinIO
# - Collaboration platforms
# - Large storage volumes
```

#### Mix Mode (mix)
```bash
# Use for combined development and design workflows
devmorph workspace create --name creative-dev-project --template default --mode mix

# Characteristics:
# - Full development stack with design capabilities
# - Shared services between dev and design
# - Asset management integration
# - Hybrid tool accessibility
```

### Mode Switching Best Practices

```bash
# Switch modes when changing development phases
devmorph workspace mode set my-project --mode dev      # Development
devmorph workspace mode set my-project --mode staging  # Testing
devmorph workspace mode set my-project --mode prod     # Production

# Best practice: Stop workspace before switching modes
devmorph workspace stop my-project
devmorph workspace mode set my-project --mode prod
devmorph workspace start my-project

# Check current mode
devmorph workspace mode show my-project
```

## Resource Management

### Docker Resource Optimization

```yaml
# docker-compose.yml - Resource-constrained services
version: '3.8'

services:
  lightweight-service:
    image: alpine:latest
    deploy:
      resources:
        limits:
          memory: 128M      # Minimal memory for simple services
          cpus: '0.1'       # Fractional CPU allocation
        reservations:
          memory: 64M
          cpus: '0.05'

  medium-service:
    image: node:18-alpine
    deploy:
      resources:
        limits:
          memory: 512M      # Moderate memory for typical applications
          cpus: '0.5'       # Half CPU core
        reservations:
          memory: 256M
          cpus: '0.25'

  heavy-service:
    image: tensorflow/tensorflow:latest
    deploy:
      resources:
        limits:
          memory: 4G        # High memory for ML/AI workloads
          cpus: '2.0'       # Two full CPU cores
        reservations:
          memory: 2G
          cpus: '1.0'
```

### Volume Management

```bash
# Regular cleanup of unused Docker resources
# Add to crontab for automatic cleanup
0 2 * * * docker system prune -f
0 3 * * 0 docker volume prune -f

# Monitor volume usage
docker system df -v

# Backup important volumes
docker run --rm -v important_data:/data -v /backup:/backup alpine tar czf /backup/data-backup.tar.gz -C /data .

# Restore volumes from backup
docker run --rm -v restored_data:/data -v /backup:/backup alpine tar xzf /backup/data-backup.tar.gz -C /data
```

### Network Optimization

```yaml
# docker-compose.yml - Network segmentation
version: '3.8'

networks:
  frontend-network:
    driver: bridge
    internal: false  # Allow internet access
    ipam:
      config:
        - subnet: 172.21.0.0/16

  backend-network:
    driver: bridge
    internal: true   # No internet access for security
    ipam:
      config:
        - subnet: 172.22.0.0/16

  database-network:
    driver: bridge
    internal: true   # Completely isolated
    ipam:
      config:
        - subnet: 172.23.0.0/16

services:
  frontend:
    # Only frontend services can access internet
    networks:
      - frontend-network

  backend:
    # Backend services isolated from internet
    networks:
      - backend-network
      - database-network  # Access to database

  database:
    # Database completely isolated
    networks:
      - database-network
```

## Security Practices

### Secure Configuration

```yaml
# docker-compose.yml - Security-hardened services
version: '3.8'

services:
  secure-app:
    image: node:18-alpine
    user: "1000:1000"  # Non-root user
    
    # Security options
    security_opt:
      - "no-new-privileges:true"
    
    # Drop all capabilities except necessary ones
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if binding to privileged ports
    
    # Read-only root filesystem when possible
    read_only: true
    tmpfs:
      - /tmp
      - /var/tmp
      - /run
    
    # No privileged access
    privileged: false
    
    # Restricted devices
    devices: []
    
    # No process escalation
    ulimits:
      nproc: 65535
      nofile:
        soft: 20000
        hard: 40000
```

### Secret Management

```bash
# Create secrets directory (never commit to version control)
mkdir -p secrets
chmod 700 secrets

# Store secrets securely
echo "my-database-password" > secrets/db_password.txt
chmod 600 secrets/db_password.txt

# Use in Docker Compose
# docker-compose.yml
version: '3.8'

services:
  app:
    secrets:
      - db_password
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Input Validation and Sanitization

```bash
#!/bin/sh
# Example of robust input validation in scripts

validate_and_sanitize_input() {
    local input="$1"
    local max_length="${2:-64}"
    
    # Check if input is provided
    if [ -z "$input" ]; then
        echo "Error: Input cannot be empty" >&2
        return 1
    fi
    
    # Check length
    if [ ${#input} -gt $max_length ]; then
        echo "Error: Input too long (max $max_length characters)" >&2
        return 1
    fi
    
    # Check for valid characters (alphanumeric, hyphen, underscore)
    if ! echo "$input" | grep -qE '^[a-zA-Z0-9_-]+$'; then
        echo "Error: Input contains invalid characters" >&2
        return 1
    fi
    
    # Check for reserved names
    case "$input" in
        "."|".."|"/")
            echo "Error: Input is a reserved name" >&2
            return 1
            ;;
    esac
    
    # Additional security checks for path traversal
    if echo "$input" | grep -qE '(\.\.|\/\/|\\\\)'; then
        echo "Error: Input contains dangerous patterns" >&2
        return 1
    fi
    
    # Return sanitized input
    echo "$input"
    return 0
}
```

### Regular Security Audits

```bash
#!/bin/sh
# Security audit script

perform_security_audit() {
    local workspace_path="$1"
    
    echo "Performing security audit for workspace: $workspace_path"
    
    # Check file permissions
    echo "Checking file permissions..."
    find "$workspace_path" -type f -perm 777 -exec ls -la {} \;
    
    # Check for world-writable directories
    echo "Checking for world-writable directories..."
    find "$workspace_path" -type d -perm -002 -exec ls -la {} \;
    
    # Check Docker image vulnerabilities
    if command -v docker >/dev/null 2>&1; then
        echo "Scanning Docker images for vulnerabilities..."
        # This would use tools like Trivy, Clair, or similar
        # trivy image --quiet my-image:tag
    fi
    
    # Check for hardcoded secrets
    echo "Checking for hardcoded secrets..."
    grep -r -i -E "(password|secret|key|token)" "$workspace_path" \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude="*.log" \
        --exclude="*.tmp" || true
    
    echo "Security audit completed"
}
```

## Workflow Optimization

### Development Workflow Patterns

```bash
# Feature branch workflow
devmorph workspace create --name feature-login-page --template frontend/react/basic --mode dev
devmorph workspace start feature-login-page

# Work on feature...
# Commit changes regularly
git add .
git commit -m "Add login page components"

# Test feature
devmorph workspace mode set feature-login-page --mode test
devmorph workspace stop feature-login-page
devmorph workspace start feature-login-page

# Merge feature and clean up
devmorph workspace destroy feature-login-page
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml - GitHub Actions integration
name: Test Workspace

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker
      uses: docker/setup-buildx-action@v2
    
    - name: Create test workspace
      run: |
        chmod +x ./devmorph
        ./devmorph workspace create --name ci-test --template default --mode test
    
    - name: Run tests
      run: |
        ./devmorph workspace start ci-test
        # Wait for services to be ready
        sleep 10
        # Run test suite
        docker-compose exec -T app npm test
    
    - name: Clean up
      if: always()
      run: |
        ./devmorph workspace destroy ci-test --force
```

### Parallel Development

```bash
# Work on multiple features simultaneously
devmorph workspace create --name feature-a --template default --mode dev &
devmorph workspace create --name feature-b --template default --mode dev &
devmorph workspace create --name feature-c --template default --mode dev &

# Wait for all workspaces to be created
wait

# Start workspaces
devmorph workspace start feature-a
devmorph workspace start feature-b
devmorph workspace start feature-c

# Work on different terminals or IDEs
# Terminal 1: cd feature-a && code .
# Terminal 2: cd feature-b && code .
# Terminal 3: cd feature-c && code .
```

### Environment Consistency

```bash
# Use environment files for consistency
cat > .env.development << EOF
NODE_ENV=development
API_URL=http://localhost:3000
DEBUG=true
EOF

cat > .env.staging << EOF
NODE_ENV=staging
API_URL=https://staging.api.example.com
DEBUG=false
EOF

cat > .env.production << EOF
NODE_ENV=production
API_URL=https://api.example.com
DEBUG=false
EOF

# Switch environments easily
cp .env.development .env
devmorph workspace start my-project
```

## Collaboration

### Team Workspace Management

```bash
# Team-shared workspaces for collaborative development
devmorph workspace create --name team-project-alpha --template default --mode dev

# Share workspace configuration
git init team-project-alpha
cd team-project-alpha
git remote add origin https://github.com/company/team-project-alpha.git
git add .
git commit -m "Initial team workspace setup"
git push -u origin main

# Team members can clone and use workspace
git clone https://github.com/company/team-project-alpha.git
cd team-project-alpha
devmorph workspace start .
```

### Code Review Workflows

```bash
# Create review workspace from specific branch
devmorph workspace create --name pr-review-123 --template default --mode dev
cd pr-review-123
git fetch origin pull/123/head:review-branch
git checkout review-branch

# Start workspace for review
devmorph workspace start pr-review-123

# Perform review in isolated environment
# Test changes, run linters, etc.

# Clean up after review
devmorph workspace destroy pr-review-123 --force
```

### Knowledge Sharing

```bash
# Create documentation workspace for team onboarding
devmorph workspace create --name team-knowledge-base --template default --mode dev
cd team-knowledge-base

# Add documentation files
mkdir -p docs/{getting-started,workflows,best-practices,troubleshooting}
touch docs/getting-started/quick-start.md
touch docs/workflows/feature-development.md
touch docs/best-practices/coding-standards.md
touch docs/troubleshooting/common-issues.md

# Start documentation workspace
devmorph workspace start team-knowledge-base

# Team members can access documentation locally
# http://localhost:3000/docs/
```

## Maintenance

### Regular Cleanup

```bash
#!/bin/sh
# Automated cleanup script

# Remove stopped workspaces older than 30 days
find . -maxdepth 1 -type d -name "*" -mtime +30 | while read dir; do
    if [ -f "$dir/.devmorph-state" ]; then
        status=$(grep '"status"' "$dir/.devmorph-state" | sed 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [ "$status" = "stopped" ] || [ "$status" = "created" ]; then
            echo "Removing old stopped workspace: $dir"
            rm -rf "$dir"
        fi
    fi
done

# Prune Docker resources
docker system prune -f

# Prune unused volumes monthly
if [ "$(date +%d)" = "01" ]; then
    docker volume prune -f
fi
```

### Backup and Recovery

```bash
#!/bin/sh
# Workspace backup script

backup_workspace() {
    local workspace_name="$1"
    local backup_dir="${2:-/backups}"
    
    # Validate workspace exists
    if [ ! -d "$workspace_name" ]; then
        echo "Error: Workspace '$workspace_name' does not exist" >&2
        return 1
    fi
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Create timestamped backup
    local timestamp=$(date -u +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/${workspace_name}_${timestamp}.tar.gz"
    
    # Create compressed backup
    tar czf "$backup_file" "$workspace_name"
    
    echo "Backup created: $backup_file"
    
    # Verify backup
    if tar tzf "$backup_file" >/dev/null 2>&1; then
        echo "Backup verified successfully"
        return 0
    else
        echo "Error: Backup verification failed" >&2
        rm -f "$backup_file"
        return 1
    fi
}

# Usage
# backup_workspace my-important-project /secure/backups
```

### Version Management

```bash
# Track workspace template versions
devmorph workspace create --name versioned-project --template frontend/react:v1.2.3 --mode dev

# Use semantic versioning for templates
ls -la templates/
# frontend/
#   react/
#     v1.0.0/
#     v1.1.0/
#     v1.2.0/
#     latest/ -> v1.2.0/

# Migrate workspace to newer template version
devmorph workspace create --name upgraded-project --template frontend/react:v1.2.3 --mode dev
```

## Performance Tuning

### Docker Performance Optimization

```yaml
# docker-compose.yml - Performance-tuned services
version: '3.8'

services:
  high-performance-app:
    image: node:18-alpine
    # CPU pinning for critical services
    cpuset: "0-1"  # Use only CPUs 0 and 1
    
    # Memory optimization
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
    
    # I/O optimization
    volumes:
      - app_data:/app/data
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 100M
    
    # Startup optimization
    init: true
    command: ["/app/start.sh"]
```

### Caching Strategies

```bash
# Docker layer caching optimization
# Dockerfile
FROM node:18-alpine

# Install dependencies first (cached layer)
COPY package*.json ./
RUN npm ci --only=production

# Copy source code last (frequently changing layer)
COPY . .

# This ensures dependencies layer is cached and reused
```

```yaml
# docker-compose.yml - Volume caching for development
version: '3.8'

services:
  dev-app:
    volumes:
      # Cache node_modules to speed up npm operations
      - /app/node_modules
      
      # Cache build artifacts
      - build_cache:/app/.cache
      
      # Mount source code for hot reloading
      - ./:/app:cached  # 'cached' mount option for Docker Desktop
```

### Monitoring and Profiling

```bash
# Monitor workspace resource usage
docker stats

# Monitor specific container
docker stats my-workspace-app

# Profile application performance
docker-compose exec app top
docker-compose exec app ps auxf

# Monitor logs for performance issues
docker-compose logs --tail=100 --follow app

# Use profiling tools inside containers
docker-compose exec app npm run profile
```

## Enterprise Usage

### Multi-Tenant Workspaces

```bash
# Create tenant-specific workspaces
devmorph workspace create --name client-a-project --template enterprise/saas --mode prod
devmorph workspace create --name client-b-project --template enterprise/saas --mode prod

# Apply tenant-specific configurations
echo "CLIENT_ID=client-a" > client-a-project/.env
echo "CLIENT_ID=client-b" > client-b-project/.env

# Isolate tenant networks
# In docker-compose.override.yml for each tenant:
# networks:
#   tenant-network:
#     name: client-a-network  # Unique per tenant
```

### Resource Quotas

```yaml
# docker-compose.yml - Resource quota enforcement
version: '3.8'

services:
  enterprise-app:
    # Strict resource limits for cost control
    deploy:
      resources:
        limits:
          memory: 1G           # Hard limit
          cpus: '0.5'
        reservations:
          memory: 512M         # Guaranteed minimum
          cpus: '0.25'
    
    # Restart limits to prevent runaway processes
    restart: on-failure:3
    
    # Health check with timeout
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

### Compliance and Auditing

```bash
#!/bin/sh
# Enterprise compliance checker

check_enterprise_compliance() {
    local workspace_name="$1"
    
    echo "Checking compliance for workspace: $workspace_name"
    
    # Check for prohibited software
    echo "Scanning for prohibited software..."
    if docker-compose exec app which svn >/dev/null 2>&1; then
        echo "WARNING: SVN detected in workspace"
    fi
    
    # Check for security policy compliance
    echo "Checking security policies..."
    # Verify no root containers
    if docker-compose config | grep -q "user: root"; then
        echo "WARNING: Root containers detected"
    fi
    
    # Check for data residency compliance
    echo "Checking data residency..."
    # Verify services don't connect to external databases without approval
    
    # Generate compliance report
    local report_file=".devmorph/reports/compliance-${workspace_name}-$(date -u +%Y%m%d).txt"
    mkdir -p "$(dirname "$report_file")"
    {
        echo "Compliance Report - $(date -u)"
        echo "Workspace: $workspace_name"
        echo "Status: COMPLIANT"
        echo "Checked by: $(whoami)"
    } > "$report_file"
    
    echo "Compliance report saved to: $report_file"
}

# Usage
# check_enterprise_compliance my-enterprise-project
```

### Centralized Management

```bash
#!/bin/sh
# Enterprise workspace manager

# Centralized workspace inventory
MANAGEMENT_DB="/var/lib/devmorph/workspaces.db"

register_workspace() {
    local workspace_name="$1"
    local owner="$2"
    local project="$3"
    local purpose="$4"
    
    # Register in central database
    echo "$(date -u +%s),$workspace_name,$owner,$project,$purpose" >> "$MANAGEMENT_DB"
}

# Usage
# register_workspace "client-project-alpha" "john.doe@company.com" "Alpha Client" "Development"

list_managed_workspaces() {
    if [ -f "$MANAGEMENT_DB" ]; then
        echo "Managed Workspaces:"
        echo "Created,Name,Owner,Project,Purpose"
        cat "$MANAGEMENT_DB"
    else
        echo "No managed workspaces registered"
    fi
}

# Enterprise policy enforcement
enforce_enterprise_policy() {
    local workspace_name="$1"
    
    # Check workspace age and enforce cleanup policies
    local workspace_age_days=$(find "$workspace_name" -maxdepth 0 -mtime +%s 2>/dev/null | xargs -I {} expr $(date +%s) - {} 2>/dev/null | xargs -I {} expr {} / 86400 2>/dev/null || echo "0")
    
    if [ "$workspace_age_days" -gt 90 ]; then
        echo "WARNING: Workspace '$workspace_name' is older than 90 days"
        echo "Consider archiving or destroying this workspace"
    fi
}
```

---

*Last updated: July 03, 2025*