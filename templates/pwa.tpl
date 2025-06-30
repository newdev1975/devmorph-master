# Progressive Web Application (PWA) Template for DevMorph Studio
# This template includes service workers and offline capabilities

services:
  pwa:
    build:
      context: .
      dockerfile: Dockerfile.pwa
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - REACT_APP_API_URL=${REACT_APP_API_URL:-http://api:8080}
      - VUE_APP_API_URL=${VUE_APP_API_URL:-http://api:8080}
      - PWA_ENABLED=true
      - OFFLINE_CACHE=true
    volumes:
      - .:/app
      - pwa_node_modules:/app/node_modules
      - pwa_dist:/app/dist
      - pwa_cache:/app/cache
    ports:
      - "${PWA_PORT:-3000}:3000"
    networks:
      - devmorph
    command: ["npm", "start"]

  api:
    build:
      context: ./api
      dockerfile: Dockerfile.api
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/pwaapi}
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
      POSTGRES_DB: ${POSTGRES_DB:-pwaapi}
      POSTGRES_USER: ${POSTGRES_USER:-pwaapi}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-pwaapi}
    volumes:
      - db_pwa_data:/var/lib/postgresql/data
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_pwa_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes

  # Build service for production PWA
  build:
    build:
      context: .
      dockerfile: Dockerfile.pwa
    environment:
      - NODE_ENV=production
      - REACT_APP_API_URL=${REACT_APP_API_URL:-https://api.example.com}
      - VUE_APP_API_URL=${VUE_APP_API_URL:-https://api.example.com}
      - PWA_ENABLED=true
      - GENERATE_SOURCEMAP=false
    volumes:
      - .:/app
      - pwa_node_modules:/app/node_modules
      - pwa_dist:/app/dist
    command: npm run build
    networks:
      - devmorph

  # Web server optimized for PWA (with service worker headers)
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - pwa_dist:/usr/share/nginx/html:ro
      - ./nginx.pwa.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - build
    networks:
      - devmorph
    # Config should include proper caching headers for PWA assets
    
  # Push notification service for PWA
  push:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=production
      - VAPID_PUBLIC_KEY=${VAPID_PUBLIC_KEY:-...}
      - VAPID_PRIVATE_KEY=${VAPID_PRIVATE_KEY:-...}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/pwaapi}
    volumes:
      - ./push:/app
    ports:
      - "3001:3001"
    depends_on:
      - db
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_pwa_data:
  redis_pwa_data:
  pwa_node_modules:
  api_node_modules:
  pwa_dist:
  pwa_cache: