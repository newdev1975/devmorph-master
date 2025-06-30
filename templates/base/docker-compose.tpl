# Base docker-compose template for DevMorph Studio
# This template provides the foundational structure for all DevMorph applications
# It supports inheritance through environment variables and service definitions

services:
  # Application-specific service will be defined in child templates
  # app:
  #   build:
  #     context: .
  #     dockerfile: Dockerfile
  #   environment:
  #     - APP_ENV=${APP_ENV:-development}
  #     - DATABASE_URL=${DATABASE_URL:-postgresql://user:password@db:5432/app}
  #   depends_on:
  #     - db
  #     - redis
  #   volumes:
  #     - .:/app
  #   networks:
  #     - devmorph

  # Database services will be included based on requirements
  # db:
  #   image: postgres:15
  #   environment:
  #     POSTGRES_DB: ${POSTGRES_DB:-app}
  #     POSTGRES_USER: ${POSTGRES_USER:-user}
  #     POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-password}
  #   volumes:
  #     - db_data:/var/lib/postgresql/data
  #   networks:
  #     - devmorph

  # Redis for caching and queues
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes

  # Web server will be included as needed
  # web:
  #   image: nginx:alpine
  #   ports:
  #     - "${WEB_PORT:-80}:80"
  #   volumes:
  #     - ./nginx.conf:/etc/nginx/nginx.conf
  #   depends_on:
  #     - app
  #   networks:
  #     - devmorph

  # Worker service for background jobs
  # worker:
  #   build:
  #     context: .
  #     dockerfile: Dockerfile.worker
  #   environment:
  #     - APP_ENV=${APP_ENV:-development}
  #   depends_on:
  #     - redis
  #     - db
  #   volumes:
  #     - .:/app
  #   networks:
  #     - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  # db_data:
  redis_data: