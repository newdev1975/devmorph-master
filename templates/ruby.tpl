# Ruby Application Template for DevMorph Studio
# This template inherits from the base template and adds Ruby-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.ruby
    environment:
      - RAILS_ENV=${RAILS_ENV:-development}
      - RACK_ENV=${RACK_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/app}
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - gem_cache:/usr/local/bundle
    ports:
      - "${APP_PORT:-3000}:${APP_PORT:-3000}"
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
      - ./nginx.ruby.conf:/etc/nginx/nginx.conf
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
  gem_cache: