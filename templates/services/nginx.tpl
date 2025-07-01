# Nginx Service Template for DevMorph Studio
# This service provides a Nginx web server instance

services:
  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./conf.d:/etc/nginx/conf.d
      - ./ssl:/etc/ssl
      - ./logs:/var/log/nginx
      - static_volume:/var/www/html
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    networks:
      - devmorph
    restart: unless-stopped
    depends_on:
      - app

networks:
  devmorph:
    driver: bridge

volumes:
  static_volume: