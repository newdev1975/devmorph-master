# PHP Application Template for DevMorph Studio
# This template inherits from the base template and adds PHP-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.php
    environment:
      - APP_ENV=${APP_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/app}
      - PHP_INI_ENV=development
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - php_extensions:/usr/local/lib/php/extensions
    ports:
      - "${APP_PORT:-9000}:9000"
    networks:
      - devmorph

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - .:/app
      - ./nginx.php.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - app
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

networks:
  devmorph:
    driver: bridge

volumes:
  db_data:
  redis_data:
  php_extensions: