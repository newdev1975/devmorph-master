# Java Application Template for DevMorph Studio
# This template inherits from the base template and adds Java-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.java
    environment:
      - JAVA_OPTS=${JAVA_OPTS:-"-Xmx1g -Xms512m"}
      - SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-dev}
      - APP_ENV=${APP_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/app}
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - maven_repo:/root/.m2
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
      - ./nginx.java.conf:/etc/nginx/nginx.conf
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
  maven_repo: