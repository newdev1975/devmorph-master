# Single Page Application (SPA) Template for DevMorph Studio
# This template provides a foundation for client-side rendered applications

services:
  spa:
    build:
      context: .
      dockerfile: Dockerfile.spa
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - REACT_APP_API_URL=${REACT_APP_API_URL:-http://api:8080}
      - VUE_APP_API_URL=${VUE_APP_API_URL:-http://api:8080}
      - API_URL=${API_URL:-http://api:8080}
    volumes:
      - .:/app
      - spa_node_modules:/app/node_modules
      - spa_dist:/app/dist
    ports:
      - "${SPA_PORT:-3000}:3000"
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
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/spaapi}
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
      POSTGRES_DB: ${POSTGRES_DB:-spaapi}
      POSTGRES_USER: ${POSTGRES_USER:-spaapi}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-spaapi}
    volumes:
      - db_spa_data:/var/lib/postgresql/data
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_spa_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes

  # Build service for production SPA
  build:
    build:
      context: .
      dockerfile: Dockerfile.spa
    environment:
      - NODE_ENV=production
      - REACT_APP_API_URL=${REACT_APP_API_URL:-https://api.example.com}
      - VUE_APP_API_URL=${VUE_APP_API_URL:-https://api.example.com}
    volumes:
      - .:/app
      - spa_node_modules:/app/node_modules
      - spa_dist:/app/dist
    command: npm run build
    networks:
      - devmorph

  # Web server for serving the SPA (handles client-side routing)
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - spa_dist:/usr/share/nginx/html:ro
      - ./nginx.spa.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - build
    networks:
      - devmorph
    # Nginx config should handle client-side routing by redirecting 404s to index.html

networks:
  devmorph:
    driver: bridge

volumes:
  db_spa_data:
  redis_spa_data:
  spa_node_modules:
  api_node_modules:
  spa_dist: