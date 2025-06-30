# Redis Service Template for DevMorph Studio
# This service provides a Redis instance for caching and queues

services:
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
      - ./redis.conf:/etc/redis/redis.conf
    ports:
      - "${REDIS_PORT:-6379}:6379"
    networks:
      - devmorph
    restart: unless-stopped
    command: redis-server --appendonly yes --maxmemory 512mb --maxmemory-policy allkeys-lru

networks:
  devmorph:
    driver: bridge

volumes:
  redis_data: