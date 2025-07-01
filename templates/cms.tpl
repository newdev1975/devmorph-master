# CMS Application Category Template for DevMorph Studio
# This template provides a foundation for Content Management System applications

services:
  cms:
    build:
      context: .
      dockerfile: Dockerfile.cms
    environment:
      - CMS_ENV=${CMS_ENV:-development}
      - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/cms}
      - CMS_ADMIN_USER=${CMS_ADMIN_USER:-admin}
      - CMS_ADMIN_PASSWORD=${CMS_ADMIN_PASSWORD:-admin}
      - CMS_SITE_NAME=${CMS_SITE_NAME:-DevMorph CMS}
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - cms_content:/app/content
      - cms_themes:/app/themes
      - cms_plugins:/app/plugins
    ports:
      - "${CMS_PORT:-8080}:8080"
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-cms}
      POSTGRES_USER: ${POSTGRES_USER:-cms}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-cms}
    volumes:
      - db_cms_data:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_cms_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - ./nginx.cms.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
      - cms_static:/app/public
    depends_on:
      - cms
    networks:
      - devmorph

  # File storage service for CMS
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
      - cms_storage:/data
    networks:
      - devmorph

  # Search service for CMS content
  search:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - node.name=search
      - cluster.name=cms-search-cluster
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    volumes:
      - search_cms_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    networks:
      - devmorph
    ulimits:
      memlock:
        soft: -1
        hard: -1

networks:
  devmorph:
    driver: bridge

volumes:
  db_cms_data:
  redis_cms_data:
  cms_content:
  cms_themes:
  cms_plugins:
  cms_static:
  cms_storage:
  search_cms_data: