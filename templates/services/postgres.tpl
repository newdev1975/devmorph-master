# PostgreSQL Service Template for DevMorph Studio
# This service provides a PostgreSQL database instance

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-app}
      POSTGRES_USER: ${POSTGRES_USER:-user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-password}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d
      - ./backups:/backups
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    networks:
      - devmorph
    restart: unless-stopped
    command: >
      postgres
      -c max_connections=200
      -c shared_buffers=256MB
      -c effective_cache_size=1GB
      -c maintenance_work_mem=64MB
      -c checkpoint_completion_target=0.9
      -c wal_buffers=16MB
      -c default_statistics_target=100
      -c random_page_cost=1.1
      -c effective_io_concurrency=200
      -c work_mem=5242kB
      -c min_wal_size=1GB
      -c max_wal_size=4GB
      -c max_worker_processes=2
      -c max_parallel_workers_per_gather=1
      -c max_parallel_workers=2
      -c max_parallel_maintenance_workers=1

networks:
  devmorph:
    driver: bridge

volumes:
  postgres_data: