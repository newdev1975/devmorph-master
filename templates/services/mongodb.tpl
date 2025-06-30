# MongoDB Service Template for DevMorph Studio
# This service provides a MongoDB database instance

services:
  mongodb:
    image: mongo:6
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USER:-root}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD:-password}
    volumes:
      - mongodb_data:/data/db
      - ./initdb:/docker-entrypoint-initdb.d
      - ./backups:/backups
    ports:
      - "${MONGO_PORT:-27017}:27017"
    networks:
      - devmorph
    restart: unless-stopped
    command: ["--wiredTigerCacheSizeGB", "1"]

networks:
  devmorph:
    driver: bridge

volumes:
  mongodb_data: