# Base Environment Variables Template for DevMorph Studio
# This template provides the foundational environment variables for all DevMorph applications

# Application Configuration
APP_NAME=DevMorph-App
APP_ENV=development
APP_KEY=
APP_DEBUG=true
APP_TIMEZONE=UTC
APP_URL=http://localhost

# Database Configuration
DB_CONNECTION=postgresql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=app
DB_USERNAME=user
DB_PASSWORD=password

# Redis Configuration
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

# Web Server Configuration
WEB_PORT=80
SSL_PORT=443

# Docker Compose Configuration
COMPOSE_PROJECT_NAME=devmorph-app

# Development-specific variables
DEV_MODE=true
HOT_RELOAD=true
DEV_TOOLS_ENABLED=true

# For production override
# APP_ENV=production
# APP_DEBUG=false
# DEV_MODE=false