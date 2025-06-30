# Traefik Service Template for DevMorph Studio
# This service provides a Traefik reverse proxy instance

services:
  traefik:
    image: traefik:v2.9
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
      - "--certificatesresolvers.myresolver.acme.email=${ACME_EMAIL:-user@example.com}"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
      - "8080:8080"  # Traefik dashboard
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt
      - ./traefik.yml:/etc/traefik/traefik.yml
    networks:
      - devmorph
    restart: unless-stopped
    depends_on:
      - app

networks:
  devmorph:
    driver: bridge

volumes:
  traefik_letsencrypt: