# DevMorph Studio Workspace Modes Documentation

DevMorph Studio supports multiple workspace modes to accommodate different development workflows and deployment scenarios. Each mode is optimized for specific use cases while maintaining consistency in the underlying architecture.

## 🚀 Available Workspace Modes

### 1. Development Mode (`docker-compose.dev.yml`)
**Purpose**: Optimized for active development with hot-reload capabilities
**Use Case**: Day-to-day development work
**Characteristics**:
- Volume mounts for real-time file changes
- Detailed logging and debugging tools enabled
- Hot-reload capabilities
- Development-specific configurations
- Access to development ports

### 2. Production Mode (`docker-compose.prod.yml`)
**Purpose**: Optimized for production deployment
**Use Case**: Live applications serving real users
**Characteristics**:
- Optimized container images (multi-stage builds)
- Security hardening
- Performance optimizations
- Minimal logging (only warnings/errors)
- Health checks and monitoring
- Resource limits and constraints

### 3. Staging Mode (`docker-compose.staging.yml`)
**Purpose**: Mirrors production environment for testing
**Use Case**: Pre-production validation
**Characteristics**:
- Production-like configurations
- Similar data structures to production
- Testing tools and monitoring
- Performance testing capabilities
- Pre-deployment validation

### 4. Testing Mode (`docker-compose.test.yml`)
**Purpose**: Dedicated environment for automated testing
**Use Case**: Running unit, integration, and end-to-end tests
**Characteristics**:
- Fresh database instances for each test run
- Isolated environment
- Test reporting and coverage tools
- Faster startup (no development tools)
- Temporary volumes for test data

### 5. Design Mode (`docker-compose.design.yml`)
**Purpose**: Focused on design and frontend development
**Use Case**: UI/UX design, frontend component development
**Characteristics**:
- Design tools integration (Storybook, Figma bridge)
- Frontend optimization services
- Asset processing capabilities
- Design system tools
- Preview and prototyping services

### 6. Mix Mode (`docker-compose.mix.yml`)
**Purpose**: Combined development and design workflow
**Use Case**: Collaborative work between developers and designers
**Characteristics**:
- Both dev and design tooling
- Real-time collaboration features
- Dual workflow support
- Shared assets and components
- Communication services for teams

## 🔧 Mode-Specific Configurations

### Environment Variables
Each mode has specific environment variables:

**Development Mode**:
```env
APP_ENV=development
DEBUG=*
HOT_RELOAD=true
DEV_TOOLS_ENABLED=true
```

**Production Mode**:
```env
APP_ENV=production
DEBUG=false
LOG_LEVEL=warn
TRUST_PROXY=true
```

**Testing Mode**:
```env
APP_ENV=test
LOG_LEVEL=error
```

**Design Mode**:
```env
APP_ENV=design
DESIGN_MODE=true
DEV_TOOLS_ENABLED=true
```

### Network Configurations
- All modes use the `devmorph` network for internal communication
- Production mode may use internal networks for security
- Development mode allows external access to debugging ports

### Volume Management
- Development: Persistent volumes with source code mounts
- Production: Optimized volumes for performance
- Testing: Temporary volumes for test isolation
- Design: Asset and preview-specific volumes

## 🔄 Mode Switching

To switch between modes, use docker-compose with the appropriate override file:

```bash
# Development mode
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production mode
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up

# Staging mode
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up

# Testing mode
docker-compose -f docker-compose.yml -f docker-compose.test.yml up

# Design mode
docker-compose -f docker-compose.yml -f docker-compose.design.yml up

# Mix mode
docker-compose -f docker-compose.yml -f docker-compose.mix.yml up
```

Or use the shorthand if the files follow the naming convention:
```bash
# For development mode (if docker-compose.dev.yml exists in the same directory)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

## 🛠️ Best Practices

1. **Mode Consistency**: Maintain similar service names across modes for consistency
2. **Environment Parity**: Keep development and production environments as similar as possible
3. **Security**: Never expose sensitive ports in production mode
4. **Performance**: Optimize for speed in development and for stability in production
5. **Observability**: Include appropriate monitoring in staging and production
6. **Isolation**: Ensure testing environments are completely isolated

## 📋 Mode-Specific Services

Some services are mode-specific:

- **Development**: Live reload services, additional debugging tools
- **Production**: Monitoring, backup, security scanning services
- **Testing**: Test runner, coverage reporting services
- **Design**: Style guide, component library services
- **Mix**: Collaboration, communication services

This mode system allows DevMorph Studio to support the complete development lifecycle while maintaining the "Dev-Design" philosophy across all stages.