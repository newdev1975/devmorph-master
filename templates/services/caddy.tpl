# Caddy Service Template for DevMorph Studio
# This service provides a Caddy web server instance

services:
  caddy:
    image: caddy:2-alpine
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
      - static_volume:/usr/share/caddy
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
      - "443:443"
    networks:
      - devmorph
    restart: unless-stopped
    depends_on:
      - app

networks:
  devmorph:
    driver: bridge

volumes:
  caddy_data:
  caddy_config:
  static_volume: