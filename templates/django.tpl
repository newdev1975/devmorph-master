# Django Application Template for DevMorph Studio
# This template extends the Python template and adds Django-specific services

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.django
    environment:
      - DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-config.settings.local}
      - DJANGO_ENV=${DJANGO_ENV:-development}
      - DATABASE_URL=postgresql://${POSTGRES_USER:-django}:${POSTGRES_PASSWORD:-django}@db:5432/${POSTGRES_DB:-django}
      - REDIS_URL=redis://redis:6379/1
      - SECRET_KEY=${SECRET_KEY:-this-is-a-secret-key-for-dev-only}
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - python_packages:/usr/local/lib/python*/site-packages
    ports:
      - "${APP_PORT:-8000}:8000"
    networks:
      - devmorph
    command: >
      sh -c "
        python manage.py collectstatic --noinput &&
        python manage.py migrate &&
        python manage.py runserver 0.0.0.0:8000
      "

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-django}
      POSTGRES_USER: ${POSTGRES_USER:-django}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-django}
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

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - ./nginx.django.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
      - static_volume:/app/staticfiles
      - media_volume:/app/media
    depends_on:
      - app
    networks:
      - devmorph

  # Celery worker for background tasks
  worker:
    build:
      context: .
      dockerfile: Dockerfile.django
    environment:
      - DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-config.settings.local}
      - DJANGO_ENV=${DJANGO_ENV:-development}
      - DATABASE_URL=postgresql://${POSTGRES_USER:-django}:${POSTGRES_PASSWORD:-django}@db:5432/${POSTGRES_DB:-django}
      - REDIS_URL=redis://redis:6379/1
    command: celery -A config worker -l info
    volumes:
      - .:/app
      - python_packages:/usr/local/lib/python*/site-packages
    depends_on:
      - db
      - redis
    networks:
      - devmorph

  # Celery beat for scheduled tasks
  beat:
    build:
      context: .
      dockerfile: Dockerfile.django
    environment:
      - DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-config.settings.local}
      - DJANGO_ENV=${DJANGO_ENV:-development}
      - DATABASE_URL=postgresql://${POSTGRES_USER:-django}:${POSTGRES_PASSWORD:-django}@db:5432/${POSTGRES_DB:-django}
      - REDIS_URL=redis://redis:6379/1
    command: celery -A config beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
    volumes:
      - .:/app
      - python_packages:/usr/local/lib/python*/site-packages
    depends_on:
      - db
      - redis
      - app
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  db_data:
  redis_data:
  python_packages:
  static_volume:
  media_volume: