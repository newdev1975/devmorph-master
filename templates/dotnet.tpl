# .NET Application Template for DevMorph Studio
# This template inherits from the base template and adds .NET-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dotnet
    environment:
      - ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT:-Development}
      - DOTNET_ENV=${DOTNET_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/app}
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - nuget_packages:/root/.nuget/packages
    ports:
      - "${APP_PORT:-5000}:${APP_PORT:-5000}"
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-app}
      POSTGRES_USER: ${POSTGRES_USER:-user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-password}
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - ./nginx.dotnet.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - app
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_data:
  redis_data:
  nuget_packages: