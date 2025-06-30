# Spring Boot Application Template for DevMorph Studio
# This template extends the Java template and adds Spring Boot-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.spring
    environment:
      - SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-dev}
      - SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/${POSTGRES_DB:-springboot}
      - SPRING_DATASOURCE_USERNAME=${POSTGRES_USER:-springboot}
      - SPRING_DATASOURCE_PASSWORD=${POSTGRES_PASSWORD:-springboot}
      - SPRING_REDIS_HOST=redis
      - SPRING_REDIS_PORT=6379
      - JAVA_OPTS=${JAVA_OPTS:-"-Xmx1g -Xms512m"}
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - maven_repo:/root/.m2
    ports:
      - "${APP_PORT:-8080}:8080"
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-springboot}
      POSTGRES_USER: ${POSTGRES_USER:-springboot}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-springboot}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8"
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d
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
      - ./nginx.spring.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - app
    networks:
      - devmorph

  # Optional: Add a test runner service for Spring Boot
  test:
    build:
      context: .
      dockerfile: Dockerfile.spring
    environment:
      - SPRING_PROFILES_ACTIVE=test
      - SPRING_DATASOURCE_URL=jdbc:h2:mem:testdb
      - JAVA_OPTS=${JAVA_OPTS:-"-Xmx1g -Xms512m"}
    command: ./mvnw test
    volumes:
      - .:/app
      - maven_repo:/root/.m2
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_data:
  redis_data:
  maven_repo: