# Rust Application Template for DevMorph Studio
# This template inherits from the base template and adds Rust-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.rust
    environment:
      - RUST_ENV=${RUST_ENV:-development}
      - APP_ENV=${APP_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/app}
      - RUST_LOG=${RUST_LOG:-debug}
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - cargo_registry:/usr/local/cargo/registry
      - cargo_git:/usr/local/cargo/git
    ports:
      - "${APP_PORT:-8080}:${APP_PORT:-8080}"
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
      - ./nginx.rust.conf:/etc/nginx/nginx.conf
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
  cargo_registry:
  cargo_git: