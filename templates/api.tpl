# API-Only Service Template for DevMorph Studio
# This template provides a foundation for microservices and API-only applications

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile.api
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - APP_ENV=${APP_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/api}
      - REDIS_URL=redis://redis:6379
      - API_VERSION=v1
      - API_RATE_LIMIT=100
      - API_RATE_WINDOW=15
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - api_node_modules:/app/node_modules
      - api_logs:/app/logs
    ports:
      - "${API_PORT:-8080}:8080"
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-api}
      POSTGRES_USER: ${POSTGRES_USER:-api}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-api}
    volumes:
      - db_api_data:/var/lib/postgresql/data
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_api_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru

  # API Gateway for routing and rate limiting
  gateway:
    image: kong:latest
    environment:
      - KONG_DATABASE=off
      - KONG_PG_HOST=db
      - KONG_PG_DATABASE=${POSTGRES_DB:-api}
      - KONG_PG_USER=${POSTGRES_USER:-api}
      - KONG_PG_PASSWORD=${POSTGRES_PASSWORD:-api}
      - KONG_PROXY_ACCESS_LOG=/dev/stdout
      - KONG_ADMIN_ACCESS_LOG=/dev/stdout
      - KONG_PROXY_ERROR_LOG=/dev/stderr
      - KONG_ADMIN_ERROR_LOG=/dev/stderr
      - KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl
    depends_on:
      - db
    ports:
      - "8000:8000"  # Proxy
      - "8443:8443"  # Proxy SSL
      - "8001:8001"  # Admin
      - "8444:8444"  # Admin SSL
    networks:
      - devmorph

  # API documentation service
  docs:
    image: swaggerapi/swagger-ui
    environment:
      - SWAGGER_JSON=/app/swagger.json
    volumes:
      - ./swagger.json:/app/swagger.json
    ports:
      - "8081:8080"
    networks:
      - devmorph
    depends_on:
      - api

  # API monitoring and metrics
  metrics:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.api.yml:/etc/prometheus/prometheus.yml
      - metrics_api_data:/prometheus
    networks:
      - devmorph

  # API testing service
  test:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - NODE_ENV=test
      - TEST_API_URL=http://api:8080
    volumes:
      - .:/app
      - api_test_node_modules:/app/node_modules
    command: npm run test:api
    depends_on:
      - api
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_api_data:
  redis_api_data:
  api_node_modules:
  api_logs:
  metrics_api_data:
  api_test_node_modules: