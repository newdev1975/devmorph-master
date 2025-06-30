# Laravel Application Template for DevMorph Studio
# This template extends the PHP template and adds Laravel-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.laravel
    environment:
      - APP_ENV=${APP_ENV:-local}
      - APP_KEY=${APP_KEY:-base64:differentBase64StringHere==}
      - DB_CONNECTION=pgsql
      - DB_HOST=db
      - DB_PORT=5432
      - DB_DATABASE=${DB_DATABASE:-laravel}
      - DB_USERNAME=${DB_USERNAME:-laravel}
      - DB_PASSWORD=${DB_PASSWORD:-laravel}
      - REDIS_HOST=redis
      - REDIS_PASSWORD=${REDIS_PASSWORD:-null}
      - REDIS_PORT=6379
      - QUEUE_CONNECTION=redis
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - php_extensions:/usr/local/lib/php/extensions
      - ./storage:/app/storage
      - ./bootstrap/cache:/app/bootstrap/cache
    ports:
      - "${APP_PORT:-9000}:9000"
    networks:
      - devmorph

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - .:/app
      - ./nginx.laravel.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - app
    networks:
      - devmorph

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-laravel}
      POSTGRES_USER: ${POSTGRES_USER:-laravel}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-laravel}
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

  queue:
    build:
      context: .
      dockerfile: Dockerfile.laravel
    environment:
      - APP_ENV=${APP_ENV:-local}
      - DB_HOST=db
      - DB_DATABASE=${DB_DATABASE:-laravel}
      - DB_USERNAME=${DB_USERNAME:-laravel}
      - DB_PASSWORD=${DB_PASSWORD:-laravel}
      - REDIS_HOST=redis
      - QUEUE_WORKER=redis
    command: php artisan queue:work --timeout=0
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - php_extensions:/usr/local/lib/php/extensions
    networks:
      - devmorph

  scheduler:
    build:
      context: .
      dockerfile: Dockerfile.laravel
    environment:
      - APP_ENV=${APP_ENV:-local}
      - DB_HOST=db
      - DB_DATABASE=${DB_DATABASE:-laravel}
      - DB_USERNAME=${DB_USERNAME:-laravel}
      - DB_PASSWORD=${DB_PASSWORD:-laravel}
    command: >
      sh -c "
        while [ true ]; do
          php artisan schedule:run --verbose --no-interaction &
          sleep 60
        done
      "
    depends_on:
      - db
    volumes:
      - .:/app
      - php_extensions:/usr/local/lib/php/extensions
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_data:
  redis_data:
  php_extensions: