# Express.js Application Template for DevMorph Studio
# This template extends the Node.js template and adds Express-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.express
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - APP_ENV=${APP_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-mongodb://db:27017/expressapp}
      - PORT=${APP_PORT:-3000}
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - node_modules:/app/node_modules
    ports:
      - "${APP_PORT:-3000}:${APP_PORT:-3000}"
    networks:
      - devmorph

  db:
    image: mongo:6
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-root}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-password}
    volumes:
      - db_data:/data/db
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
      - .:/app
      - ./nginx.express.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - app
    networks:
      - devmorph

  # Optional: Add a test runner service
  test:
    build:
      context: .
      dockerfile: Dockerfile.express
    environment:
      - NODE_ENV=test
      - TEST_DATABASE_URL=${TEST_DATABASE_URL:-mongodb://testdb:27017/expressapp_test}
    command: npm run test
    depends_on:
      - db
    volumes:
      - .:/app
      - node_modules:/app/node_modules
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_data:
  redis_data:
  node_modules: