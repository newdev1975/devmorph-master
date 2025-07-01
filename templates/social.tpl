# Social Media Application Category Template for DevMorph Studio
# This template provides a foundation for social media applications with real-time features

services:
  social:
    build:
      context: .
      dockerfile: Dockerfile.social
    environment:
      - APP_ENV=${APP_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/social}
      - REDIS_URL=redis://redis:6379
      - MONGO_URL=mongodb://mongo:27017/social
      - REALTIME_ENABLED=true
      - NOTIFICATIONS_ENABLED=true
      - MESSAGES_ENABLED=true
    depends_on:
      - db
      - redis
      - mongo
    volumes:
      - .:/app
      - social_uploads:/app/uploads
      - social_data:/app/data
    ports:
      - "${SOCIAL_PORT:-3000}:3000"
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-social}
      POSTGRES_USER: ${POSTGRES_USER:-social}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-social}
    volumes:
      - db_social_data:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d
    networks:
      - devmorph

  mongo:
    image: mongo:6
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-social}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-social}
    volumes:
      - mongo_social_data:/data/db
      - ./initdb:/docker-entrypoint-initdb.d
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_social_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes --maxmemory 1gb --maxmemory-policy allkeys-lru

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - ./nginx.social.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
      - social_static:/usr/share/nginx/html
    depends_on:
      - social
    networks:
      - devmorph

  # Real-time messaging service
  messaging:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=development
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/social}
    volumes:
      - ./messaging:/app
    ports:
      - "3001:3001"
    depends_on:
      - redis
      - db
    networks:
      - devmorph

  # Notification service
  notifications:
    image: node:18-alpine
    working_dir: /app
    command: npm start
    environment:
      - NODE_ENV=development
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/social}
      - SMTP_HOST=${SMTP_HOST:-localhost}
      - SMTP_USER=${SMTP_USER:-user}
      - SMTP_PASS=${SMTP_PASS:-password}
    volumes:
      - ./notifications:/app
    ports:
      - "3002:3002"
    depends_on:
      - redis
      - db
    networks:
      - devmorph

  # Image processing service for social media content
  image-processor:
    image: node:18-alpine
    working_dir: /app
    command: >
      sh -c "
        npm install -g sharp-cli &&
        while inotifyd -c 'echo \"File changed\"' /app/uploads/; do
          echo \"Processing uploaded images...\";
          find /app/uploads -name '*.jpg' -o -name '*.png' | xargs -I {} sharp --out {} --resize 1200x1200^ --quality 80
        done
      "
    volumes:
      - social_uploads:/app/uploads
    networks:
      - devmorph

  # File storage service
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
      - social_storage:/data
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_social_data:
  mongo_social_data:
  redis_social_data:
  social_uploads:
  social_data:
  social_static:
  social_storage: