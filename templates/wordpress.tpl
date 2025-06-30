# WordPress Application Template for DevMorph Studio
# This template extends the PHP template and adds WordPress-specific services

services:
  app:
    image: wordpress:6-php8.2-fpm
    environment:
      - WORDPRESS_DB_HOST=db:3306
      - WORDPRESS_DB_USER=${WORDPRESS_DB_USER:-wordpress}
      - WORDPRESS_DB_PASSWORD=${WORDPRESS_DB_PASSWORD:-wordpress}
      - WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME:-wordpress}
    depends_on:
      - db
    volumes:
      - wordpress_data:/var/www/html
      - ./wp-content:/var/www/html/wp-content
      - ./custom.ini:/usr/local/etc/php/conf.d/custom.ini
    networks:
      - devmorph

  db:
    image: mysql:8.0
    environment:
      - MYSQL_DATABASE=${WORDPRESS_DB_NAME:-wordpress}
      - MYSQL_USER=${WORDPRESS_DB_USER:-wordpress}
      - MYSQL_PASSWORD=${WORDPRESS_DB_PASSWORD:-wordpress}
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-rootpassword}
    volumes:
      - db_data:/var/lib/mysql
      - ./initdb:/docker-entrypoint-initdb.d
    networks:
      - devmorph

  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - wordpress_data:/var/www/html
      - ./nginx.wordpress.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - app
    networks:
      - devmorph

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - devmorph
    command: redis-server --appendonly yes

  # phpMyAdmin for database management
  adminer:
    image: adminer
    ports:
      - 8080:8080
    environment:
      - ADMINER_DEFAULT_SERVER=db
      - ADMINER_DESIGN=pepa-linha
    depends_on:
      - db
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  wordpress_data:
  db_data:
  redis_data: