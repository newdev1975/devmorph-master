# React Application Template for DevMorph Studio
# This template extends the Node.js template and adds React-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.react
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - REACT_APP_API_URL=${REACT_APP_API_URL:-http://api:8080}
      - REACT_APP_ENV=${REACT_APP_ENV:-development}
      - PORT=${APP_PORT:-3000}
    depends_on:
      - api
    volumes:
      - .:/app
      - node_modules:/app/node_modules
    ports:
      - "${APP_PORT:-3000}:${APP_PORT:-3000}"
    networks:
      - devmorph
    # For development, we want the container to start but not immediately exit
    command: ["npm", "start"]

  api:
    build:
      context: ./api
      dockerfile: Dockerfile.api
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/reactapi}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - ./api:/app
      - api_node_modules:/app/node_modules
    ports:
      - "8080:8080"
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-reactapi}
      POSTGRES_USER: ${POSTGRES_USER:-reactapi}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-reactapi}
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

  # For production builds
  build:
    build:
      context: .
      dockerfile: Dockerfile.react
    environment:
      - NODE_ENV=production
      - REACT_APP_API_URL=${REACT_APP_API_URL:-http://api:8080}
    volumes:
      - .:/app
      - node_modules:/app/node_modules
      - build_output:/app/build
    command: npm run build
    networks:
      - devmorph

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - build_output:/usr/share/nginx/html
      - ./nginx.react.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - build
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_data:
  redis_data:
  node_modules:
  api_node_modules:
  build_output: