# Apache Service Template for DevMorph Studio
# This service provides an Apache web server instance

services:
  apache:
    image: httpd:2.4
    volumes:
      - ./httpd.conf:/usr/local/apache2/conf/httpd.conf
      - ./conf.d:/usr/local/apache2/conf/extra
      - ./ssl:/usr/local/apache2/conf/ssl
      - ./logs:/usr/local/apache2/logs
      - static_volume:/usr/local/apache2/htdocs
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