# E-commerce Application Category Template for DevMorph Studio
# This template provides a foundation for e-commerce applications with payment and inventory

services:
  ecommerce:
    build:
      context: .
      dockerfile: Dockerfile.ecommerce
    environment:
      - APP_ENV=${APP_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/ecommerce}
      - REDIS_URL=redis://redis:6379
      - PAYMENT_GATEWAY=${PAYMENT_GATEWAY:-stripe}
      - PAYMENT_PUBLIC_KEY=${PAYMENT_PUBLIC_KEY:-pk_test_...}
      - PAYMENT_SECRET_KEY=${PAYMENT_SECRET_KEY:-sk_test_...}
      - INVENTORY_ENABLED=true
      - CART_TTL=3600
    depends_on:
      - db
      - redis
      - payment
    volumes:
      - .:/app
      - ecommerce_uploads:/app/uploads
      - ecommerce_data:/app/data
    ports:
      - "${ECOMMERCE_PORT:-3000}:3000"
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-ecommerce}
      POSTGRES_USER: ${POSTGRES_USER:-ecommerce}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-ecommerce}
    volumes:
      - db_ecommerce_data:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_ecommerce_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes --maxmemory 512mb --maxmemory-policy allkeys-lru

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - ./nginx.ecommerce.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
      - ecommerce_static:/usr/share/nginx/html
    depends_on:
      - ecommerce
    networks:
      - devmorph

  # Payment service for e-commerce transactions
  payment:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=development
      - PAYMENT_PROVIDER=stripe
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY:-sk_test_...}
      - STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET:-whsec_...}
    volumes:
      - ./payment:/app
    ports:
      - "3001:3001"
    networks:
      - devmorph

  # Inventory service to manage stock
  inventory:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=development
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/ecommerce}
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./inventory:/app
    ports:
      - "3002:3002"
    depends_on:
      - db
      - redis
    networks:
      - devmorph

  # Order processing service
  orders:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=development
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/ecommerce}
      - REDIS_URL=redis://redis:6379
      - SMTP_HOST=${SMTP_HOST:-localhost}
      - SMTP_USER=${SMTP_USER:-user}
      - SMTP_PASS=${SMTP_PASS:-password}
    volumes:
      - ./orders:/app
    ports:
      - "3003:3003"
    depends_on:
      - db
      - redis
    networks:
      - devmorph

  # File storage for product images
  storage:
    image: minio/minio:latest
    environment:
      - MINIO_ROOT_USER=${S3_ACCESS_KEY:-minioadmin}
      - MINIO_ROOT_PASSWORD=${S3_SECRET_KEY:-minioadmin}
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - ecommerce_storage:/data
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_ecommerce_data:
  redis_ecommerce_data:
  ecommerce_uploads:
  ecommerce_data:
  ecommerce_static:
  ecommerce_storage: