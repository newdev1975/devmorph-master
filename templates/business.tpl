# Business Applications Category Template for DevMorph Studio
# This template provides a foundation for business applications with reporting and analytics

services:
  business:
    build:
      context: .
      dockerfile: Dockerfile.business
    environment:
      - APP_ENV=${APP_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/business}
      - REDIS_URL=redis://redis:6379
      - REPORTS_ENABLED=true
      - ANALYTICS_ENABLED=true
      - ERP_ENABLED=true
      - CRM_ENABLED=true
    depends_on:
      - db
      - redis
      - reports
    volumes:
      - .:/app
      - business_data:/app/data
      - business_reports:/app/reports
    ports:
      - "${BUSINESS_PORT:-3000}:3000"
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-business}
      POSTGRES_USER: ${POSTGRES_USER:-business}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-business}
    volumes:
      - db_business_data:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_business_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes --maxmemory 512mb --maxmemory-policy allkeys-lru

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - ./nginx.business.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
      - business_static:/usr/share/nginx/html
    depends_on:
      - business
    networks:
      - devmorph

  # Reporting service
  reports:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=development
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/business}
      - REPORTS_STORAGE_PATH=/reports
      - CHARTING_LIB=chart.js
    volumes:
      - ./reports:/app
      - business_reports:/reports
    ports:
      - "3001:3001"
    depends_on:
      - db
    networks:
      - devmorph

  # Analytics service
  analytics:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=development
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/business}
      - REDIS_URL=redis://redis:6379
      - ANALYTICS_ENGINE=custom
    volumes:
      - ./analytics:/app
    ports:
      - "3002:3002"
    depends_on:
      - db
      - redis
    networks:
      - devmorph

  # Business intelligence service
  bi:
    image: metabase/metabase
    environment:
      - MB_DB_FILE=/metabase-data/metabase.db
      - JAVA_OPTS=-Xmx3g -Xms1g
    volumes:
      - business_bi_data:/metabase-data
      - ./metabase-setup:/setup
    ports:
      - "3003:3000"
    depends_on:
      - db
    networks:
      - devmorph

  # Document generation service
  documents:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=development
      - DOCUMENT_TEMPLATES_PATH=/templates
      - DOCUMENT_OUTPUT_PATH=/output
    volumes:
      - ./documents:/app
      - business_documents:/output
      - business_templates:/templates
    ports:
      - "3004:3004"
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_business_data:
  redis_business_data:
  business_data:
  business_reports:
  business_static:
  business_bi_data:
  business_documents:
  business_templates: